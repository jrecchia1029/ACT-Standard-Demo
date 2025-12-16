#!/usr/bin/env python3
# random_iperf_traffic_ranges_pw.py
'''
sudo python3 iperf_random_traffic_generator.py \
    --devices 10.18.176.211 10.18.176.204 \
    --username cvpadmin --password arista123 \
    --flows 8 --concurrency 4 --jitter 0.1 \
    --udp-fraction 0.5 --duration-range 240-300 \
    --tcp-bandwidth-range 100M-500M --udp-bandwidth-range 100M-500M \
    --parallel-range 1-4
'''

import argparse, getpass, json, random, re, sys, time
from typing import Dict, List, Optional, Pattern, Tuple
import ipaddress
import paramiko
from concurrent.futures import ThreadPoolExecutor, as_completed

# ---------------- SSH ----------------
class SSH:
    def __init__(self, host: str, username: str, password: str, timeout=10):
        self.host, self.username, self.password, self.timeout = host, username, password, timeout
        self.cli: Optional[paramiko.SSHClient] = None
    def connect(self):
        c = paramiko.SSHClient()
        c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        c.connect(self.host, username=self.username, password=self.password,
                  timeout=self.timeout, banner_timeout=self.timeout,
                  auth_timeout=self.timeout, look_for_keys=False, allow_agent=False)
        self.cli = c
    def close(self):
        if self.cli:
            try: self.cli.close()
            except: pass
    def run(self, cmd: str, pty: bool = True, timeout: Optional[int] = None) -> Tuple[int,str,str]:
        assert self.cli, "SSH not connected"
        chan = self.cli.get_transport().open_session()
        if pty: chan.get_pty()
        chan.exec_command(cmd)
        if timeout is not None: chan.settimeout(timeout)
        out = chan.makefile("r", -1).read()
        err = chan.makefile_stderr("r", -1).read()
        rc = chan.recv_exit_status()
        return rc, (out or "").strip(), (err or "").strip()

# ------------- Helpers ---------------
class RangeError(ValueError): pass
def parse_int_range(r: Optional[str], min_allowed=1, name="range") -> Optional[Tuple[int,int]]:
    if not r: return None
    lo_s, hi_s = r.split("-",1)
    lo, hi = int(lo_s), int(hi_s)
    if lo < min_allowed or hi < min_allowed or lo > hi: raise RangeError(f"{name} must be >={min_allowed} and min<=max")
    return (lo,hi)

def parse_bw_range(r: Optional[str]) -> Optional[Tuple[int,int,str]]:
    if not r: return None
    lo_s, hi_s = r.split("-",1)
    def split(s):
        s=s.strip(); num="".join(ch for ch in s if ch.isdigit() or ch=="."); unit=s[len(num):].strip().upper()
        if not num or unit not in ("K","M","G"): raise RangeError("bandwidth endpoints must include unit K/M/G, e.g., 10M-200M")
        return int(float(num)), unit
    lo,u1 = split(lo_s); hi,u2 = split(hi_s)
    if u1!=u2 or lo<=0 or hi<=0 or lo>hi: raise RangeError("bandwidth range must use same unit and min<=max")
    return (lo,hi,u1)

def sample_int(base: int, rng: Optional[Tuple[int,int]]) -> int:
    return random.randint(*rng) if rng else base

def sample_bw(fixed: Optional[str], rng: Optional[Tuple[int,int,str]]) -> Optional[str]:
    if rng:
        lo,hi,u=rng
        return f"{random.randint(lo,hi)}{u}"
    return fixed

def ip_ok(ip: str, include_loopback: bool, exclude_cidrs: List[ipaddress._BaseNetwork]) -> bool:
    try:
        addr = ipaddress.ip_address(ip)
    except ValueError:
        return False
    if addr.version != 4:
        return False  # this script focuses on IPv4; add IPv6 later if needed
    if addr.is_loopback and not include_loopback:
        return False
    for n in exclude_cidrs:
        if addr in n: return False
    return True

# ---------- vEOS discovery ----------
def fetch_interfaces_json(ssh: SSH) -> dict:
    rc,out,err = ssh.run("show ip interface Ethernet 1-$ | json")
    print(rc)
    print(out)
    if rc != 0 or not out:
        raise RuntimeError(f"Failed to get interface JSON on {ssh.host}: {err or out}")
    return json.loads(out)

def discover_endpoints(
    ssh: SSH,
    vrf_allow, vrf_deny,
    if_allow, if_deny,
    include_loopback: bool,
    exclude_cidrs
) -> List[Dict[str, str]]:
    """
    Discover endpoints from 'show ip interface Ethernet 1-$ | json'.
    Returns: [{'device', 'ip', 'vrf', 'intf'}, ...]
    """
    data = fetch_interfaces_json(ssh)
    endpoints: List[Dict[str,str]] = []
    ifaces = data.get("interfaces") or {}

    def maybe_add(ip: str, vrf: str, ifname: str):
        # Filters
        if if_allow and not if_allow.search(ifname):   return
        if if_deny and if_deny.search(ifname):         return
        if vrf_allow and not vrf_allow.search(vrf):    return
        if vrf_deny and vrf_deny.search(vrf):          return
        # IP acceptance
        if not ip_ok(ip, include_loopback, exclude_cidrs): return
        endpoints.append({"device": ssh.host, "ip": ip, "vrf": vrf, "intf": ifname})

    for ifname, idef in ifaces.items():
        vrf = (idef.get("vrf") or "default")
        ia  = idef.get("interfaceAddress") or {}

        # Primary
        prim = ia.get("primaryIp") or {}
        ip_primary = prim.get("address")
        if ip_primary:
            maybe_add(ip_primary, vrf, ifname)

        # Secondaries can appear in a few shapes across EOS versions:
        # 1) dict of ip -> {maskLen: N} or ip -> {}
        secs = ia.get("secondaryIps")
        if isinstance(secs, dict):
            for k, v in secs.items():
                # key may already be the IP, or value may have "address"
                ip = k if isinstance(k, str) and k.count(".") == 3 else (v.get("address") if isinstance(v, dict) else None)
                if ip:
                    maybe_add(ip, vrf, ifname)

        # 2) list under "secondaryIpsOrderedList" (strings like "x.y.z.w" or "x.y.z.w/len")
        for item in (ia.get("secondaryIpsOrderedList") or []):
            ip = item.split("/", 1)[0] if isinstance(item, str) else None
            if ip:
                maybe_add(ip, vrf, ifname)

        # Some images expose "interfaceAddressBrief.ipAddr.address" as a duplicate of primary;
        # we skip it because we already captured primary above.

    return endpoints

# ---------- Iperf commands (VRF-aware) ----------
def vrf_exec_cmd(vrf: str, cmd: str) -> str:
    return f"ip netns exec ns-{vrf} {cmd}"

def start_server_for_ip(ssh: SSH, ip: str, vrf: str, log_path: str = None) -> Tuple[bool,str]:
    log_path = log_path or f"/tmp/iperf3_server_{ip.replace('.','_')}.log"
    base = f"iperf -s -B {ip}"
    cmd  = f"bash timeout 600 sudo nohup {vrf_exec_cmd(vrf, base)} > {log_path} 2>&1 & echo $!"
    rc,out,err = ssh.run(cmd)
    ok = (rc==0 and out.strip()!="")
    return ok, (out.strip() if ok else (err or out or f"rc={rc}"))

def start_client_bg(ssh: SSH, src_ip: str, src_vrf: str, dst_ip: str,
                    duration: int, bandwidth: Optional[str], parallel: int,
                    protocol: str, reverse: bool, log_path: str) -> Tuple[bool,str]:
    parts = ["iperf", "-c", dst_ip, "-t", str(duration), "-B", src_ip]
    if protocol == "udp": parts.append("-u")
    if bandwidth: parts += ["-b", bandwidth]
    if parallel > 1: parts += ["-P", str(parallel)]
    if reverse and protocol == "tcp": parts.append("-R")
    base = " ".join(parts)
    cmd  = f"bash timeout 600 sudo nohup {vrf_exec_cmd(src_vrf, base)} > {log_path} 2>&1 & echo $!"
    rc,out,err = ssh.run(cmd)
    ok = (rc==0 and out.strip()!="")
    return ok, (out.strip() if ok else (err or out or f"rc={rc}"))

# ---------- Orchestrator ----------
class Orchestrator:
    def __init__(self,
                 devices: List[str],
                 username: str, password: str,
                 flows: int,
                 duration: int, duration_range: Optional[Tuple[int,int]],
                 tcp_bw_fixed: Optional[str], tcp_bw_rng: Optional[Tuple[int,int,str]],
                 udp_bw_fixed: Optional[str], udp_bw_rng: Optional[Tuple[int,int,str]],
                 par_fixed: int, par_rng: Optional[Tuple[int,int]],
                 udp_fraction: float, reverse_rate: float,
                 concurrency: int, jitter: float,
                 vrf_allow: Optional[Pattern], vrf_deny: Optional[Pattern],
                 if_allow: Optional[Pattern], if_deny: Optional[Pattern],
                 include_loopback: bool, exclude_cidrs: List[ipaddress._BaseNetwork],
                 dry_run: bool, seed: Optional[int]):

        if seed is not None: random.seed(seed)
        self.username=username; self.password=password
        self.devices_hosts = sorted(set(devices))
        self.device_ssh: Dict[str, SSH] = {d: SSH(d, username, password) for d in self.devices_hosts}
        self.flows=flows
        self.base_dur=duration; self.dur_rng=duration_range
        self.tcp_bw_fixed=tcp_bw_fixed; self.tcp_bw_rng=tcp_bw_rng
        self.udp_bw_fixed=udp_bw_fixed or "10M"; self.udp_bw_rng=udp_bw_rng
        self.par_fixed=max(1,par_fixed); self.par_rng=par_rng
        self.udp_fraction=max(0.0,min(1.0,udp_fraction))
        self.reverse_rate=max(0.0,min(1.0,reverse_rate))
        self.concurrency=max(1,concurrency); self.jitter=max(0.0,jitter)
        self.vrf_allow=vrf_allow; self.vrf_deny=vrf_deny
        self.if_allow=if_allow; self.if_deny=if_deny
        self.include_loopback=include_loopback; self.exclude_cidrs=exclude_cidrs
        self.dry=dry_run

        # endpoints discovered later
        self.endpoints: List[Dict[str,str]] = []  # each: device, ip, vrf, intf

        # tracking pids per device
        self.server_pids: Dict[str,List[str]] = {d: [] for d in self.devices_hosts}
        self.client_pids: Dict[str,List[str]] = {d: [] for d in self.devices_hosts}

    def log(self,*a): print("[+]",*a)

    def connect_devices(self):
        self.log("Connecting to devices in parallel...")
        if self.dry:
            self.log("(dry) would connect:", ", ".join(self.devices_hosts))
            return
        with ThreadPoolExecutor(max_workers=min(self.concurrency, len(self.devices_hosts) or 1)) as ex:
            futures = {ex.submit(self.device_ssh[d].connect): d for d in self.devices_hosts}
            for fut in as_completed(futures):
                d = futures[fut]
                try:
                    fut.result()
                    self.log(f"  Connected successfully to {d}")
                except Exception as e:
                    self.log(f"  ERROR connecting to {d}: {e.__class__.__name__}: {e}")

    def discover_all_endpoints(self):
        self.log("Auto-discovering IPv4 endpoints (all VRFs, all interfaces) ...")
        if self.dry:
            # fabricate example endpoints for dry-run verbosity
            for d in self.devices_hosts:
                self.endpoints += [{"device": d, "ip": f"10.0.{i}.2", "vrf": "default", "intf": f"Ethernet{i}"} for i in range(1,3)]
            self.log(f"(dry) discovered {len(self.endpoints)} endpoints")
            return

        for d in self.devices_hosts:
            eps = discover_endpoints(self.device_ssh[d],
                                     self.vrf_allow, self.vrf_deny,
                                     self.if_allow, self.if_deny,
                                     self.include_loopback, self.exclude_cidrs)
            self.log(f"  {d}: found {len(eps)} endpoint(s)")
            for e in eps:
                self.log(f"    {e['ip']} vrf={e['vrf']} intf={e['intf']}")
            self.endpoints += eps
        if len(self.endpoints) < 2:
            raise RuntimeError("Discovered fewer than two endpoints. Add addresses to interfaces or adjust filters.")

    def start_servers_for_all_endpoints(self):
        self.log("Starting iperf3 servers (one per endpoint IP) inside their VRFs...")
        def start_one(e):
            if self.dry:
                self.log(f"(dry) {e['device']}: start server in vrf {e['vrf']} bound to {e['ip']}")
                return True, "DRY", e
            ok,pid = start_server_for_ip(self.device_ssh[e["device"]], e["ip"], e["vrf"])
            if ok: self.server_pids[e["device"]].append(pid)
            return ok,pid,e

        with ThreadPoolExecutor(max_workers=min(self.concurrency, len(self.endpoints) or 1)) as ex:
            futs = {ex.submit(start_one, e): e for e in self.endpoints}
            for fut in as_completed(futs):
                ok,pid,e = fut.result()
                if ok: self.log(f"  {e['ip']}: server PID {pid}")
                else:  self.log(f"  {e['ip']}: FAILED to start server ({pid})")

    def _plan_flows(self) -> List[dict]:
        ips = self.endpoints
        plans=[]
        for i in range(self.flows):
            src, dst = random.sample(ips, 2)
            proto = "udp" if random.random() < self.udp_fraction else "tcp"
            reverse = (proto=="tcp") and (random.random() < self.reverse_rate)
            dur = sample_int(self.base_dur, self.dur_rng)
            par = sample_int(self.par_fixed, self.par_rng)
            if proto=="tcp":
                bw = sample_bw(self.tcp_bw_fixed, self.tcp_bw_rng)  # may be None
            else:
                bw = sample_bw(self.udp_bw_fixed, self.udp_bw_rng) or "10M"
            plans.append({
                "i": i,
                "src": src, "dst": dst,
                "proto": proto, "reverse": reverse, "dur": dur, "par": par, "bw": bw,
                "log": f"/tmp/iperf3_client_{i}_{int(time.time())}.log"
            })
        return plans

    def launch_flows_parallel(self):
        plans = self._plan_flows()
        self.log(f"Launching {len(plans)} flows with concurrency={self.concurrency} …")
        for p in plans:
            self.log(f"  plan {p['i']+1}: {p['src']['device']}:{p['src']['ip']}({p['src']['vrf']}) -> "
                     f"{p['dst']['device']}:{p['dst']['ip']}({p['dst']['vrf']}) "
                     f"{p['proto'].upper()} t={p['dur']}s -b={p['bw'] or 'auto'} -P {p['par']} reverse={p['reverse']}")
        def launch(p):
            if self.jitter>0: time.sleep(random.uniform(0, self.jitter))
            if self.dry:
                self.log(f"(dry) launch {p['src']['ip']} -> {p['dst']['ip']} in vrf {p['src']['vrf']}")
                return True, "DRY", p
            dev = p["src"]["device"]
            ok,pid = start_client_bg(self.device_ssh[dev],
                                     src_ip=p["src"]["ip"], src_vrf=p["src"]["vrf"], dst_ip=p["dst"]["ip"],
                                     duration=p["dur"], bandwidth=p["bw"], parallel=p["par"],
                                     protocol=p["proto"], reverse=p["reverse"], log_path=p["log"])
            if ok: self.client_pids[dev].append(pid)
            return ok,pid,p
        with ThreadPoolExecutor(max_workers=self.concurrency) as ex:
            futs = {ex.submit(launch, p): p for p in plans}
            for fut in as_completed(futs):
                try:
                    ok,pid,p = fut.result()
                    if ok: self.log(f"  started flow {p['i']+1} on {p['src']['device']} pid={pid}")
                    else:  self.log(f"  FAILED flow {p['i']+1} on {p['src']['device']}: {pid}")
                except Exception as e:
                    self.log(f"  EXCEPTION in flow: {e}")

    def cleanup(self):
        self.log("Cleanup (best-effort): clients then servers…")
        if self.dry:
            self.log("(dry) cleanup skipped")
            return
        # stop clients
        for dev,pids in self.client_pids.items():
            if not pids: continue
            pids = [str(int(pid)) for pid in pids]
            rc,out,err = self.device_ssh[dev].run(f"bash timeout 30 kill {' '.join(pids)} 2>/dev/null || true")
            self.log(f"  {dev} clients: {out or 'killed'}")
        # stop servers
        for dev,pids in self.server_pids.items():
            if not pids: continue
            pids = [str(int(pid)) for pid in pids]
            rc,out,err = self.device_ssh[dev].run(f"bash timeout 30 kill {' '.join(pids)} 2>/dev/null || true")
            self.log(f"  {dev} servers: {out or 'killed'}")
        for ssh in self.device_ssh.values():
            ssh.close()

    def run(self):
        try:
            self.connect_devices()
            self.discover_all_endpoints()
            self.start_servers_for_all_endpoints()
            self.log("Waiting 2s for servers to be ready…"); time.sleep(2)
            self.launch_flows_parallel()
            max_dur = (self.dur_rng[1] if self.dur_rng else self.base_dur)
            self.log(f"Waiting ~{max_dur+2}s for flows to complete…"); time.sleep(max_dur+2)
        except KeyboardInterrupt:
            self.log("Interrupted, cleaning up…")
        finally:
            self.cleanup()
            self.log("Done.")

# -------------- CLI ---------------
def parse_args():
    p = argparse.ArgumentParser(description="vEOS VRF-aware iperf3 generator: auto-discovers all IPv4 endpoints.")
    # Devices (management reachability)
    p.add_argument("--devices", "-D", nargs="+", required=True,
                   help="vEOS device hostnames/IPs to SSH into (mgmt).")
    p.add_argument("--username", "-u", required=True)
    g = p.add_mutually_exclusive_group(required=True)
    g.add_argument("--password")
    g.add_argument("--ask_pass", action="store_true")

    # Flow count & randomness
    p.add_argument("--flows", "-n", type=int, default=40)
    p.add_argument("--duration", "-t", type=int, default=20)
    p.add_argument("--duration-range", type=str, help="min-max seconds, e.g. 10-60")
    p.add_argument("--bandwidth", "-b", type=str, help="Fixed TCP -b; ignored if TCP range is set.")
    p.add_argument("--tcp-bandwidth-range", type=str, help="e.g. 50M-400M")
    p.add_argument("--udp-bandwidth", type=str, help="Fixed UDP -b; default 10M if none.")
    p.add_argument("--udp-bandwidth-range", type=str, help="e.g. 5M-50M")
    p.add_argument("--parallel", "-P", type=int, default=1)
    p.add_argument("--parallel-range", type=str, help="min-max, e.g. 1-6")
    p.add_argument("--udp-fraction", type=float, default=0.3)
    p.add_argument("--reverse-rate", type=float, default=0.2)

    # Parallelism for launching
    p.add_argument("--concurrency", type=int, default=12)
    p.add_argument("--jitter", type=float, default=0.2)

    # Discovery filters (optional)
    p.add_argument("--include-vrfs", type=str, help="Regex of VRFs to include (default: all).")
    p.add_argument("--exclude-vrfs", type=str, help="Regex of VRFs to exclude (e.g., '^mgmt$').")
    p.add_argument("--include-ifs", type=str, help="Regex of interfaces to include (default: all).")
    p.add_argument("--exclude-ifs", type=str, help="Regex of interfaces to exclude.")
    p.add_argument("--include-loopback", action="store_true", help="Include 127.0.0.0/8 loopbacks (default: skip).")
    p.add_argument("--exclude-cidrs", nargs="*", default=["169.254.0.0/16", "127.0.0.0/8"],
                   help="CIDRs to exclude from endpoints (default: link-local & loopback).")

    p.add_argument("--dry-run", action="store_true")
    p.add_argument("--seed", type=int)
    return p.parse_args()

if __name__ == "__main__":
    args = parse_args()
    password = args.password if not args.ask_pass else getpass.getpass("SSH password: ")

    # Parse ranges
    try:
        dur_rng = parse_int_range(args.duration_range, 1, "duration-range")
        par_rng = parse_int_range(args.parallel_range, 1, "parallel-range")
        tcp_rng = parse_bw_range(args.tcp_bandwidth_range)
        udp_rng = parse_bw_range(args.udp_bandwidth_range)
    except RangeError as e:
        print(f"Error: {e}", file=sys.stderr); sys.exit(2)

    # Compile include/exclude regexes
    vrf_allow = re.compile(args.include_vrfs) if args.include_vrfs else None
    vrf_deny  = re.compile(args.exclude_vrfs) if args.exclude_vrfs else None
    if_allow  = re.compile(args.include_ifs)  if args.include_ifs  else None
    if_deny   = re.compile(args.exclude_ifs)  if args.exclude_ifs  else None

    # CIDR excludes
    exclude_cidrs = []
    for c in (args.exclude_cidrs or []):
        try:
            exclude_cidrs.append(ipaddress.ip_network(c, strict=False))
        except Exception:
            print(f"Warning: skipping invalid CIDR '{c}'", file=sys.stderr)

    orch = Orchestrator(
        devices=args.devices, username=args.username, password=password,
        flows=args.flows,
        duration=args.duration, duration_range=dur_rng,
        tcp_bw_fixed=args.bandwidth, tcp_bw_rng=tcp_rng,
        udp_bw_fixed=args.udp_bandwidth, udp_bw_rng=udp_rng,
        par_fixed=args.parallel, par_rng=par_rng,
        udp_fraction=args.udp_fraction, reverse_rate=args.reverse_rate,
        concurrency=args.concurrency, jitter=args.jitter,
        vrf_allow=vrf_allow, vrf_deny=vrf_deny, if_allow=if_allow, if_deny=if_deny,
        include_loopback=args.include_loopback, exclude_cidrs=exclude_cidrs,
        dry_run=args.dry_run, seed=args.seed
    )
    while True:
        orch.run()
