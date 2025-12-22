# NetSec-Lab-Tools

## Overview
A collection of scripts for ethical hacking labs, starting with a bash port scanner for recon in a safe VM setup (Kali attacker, Metasploitable 2 target on host-only network). Detects open ports, services, and high-level Metasploit exploits/vulns.

## Lab Setup
- Attacker: Kali Linux in VirtualBox (IP: 192.168.56.101)
- Target: Metasploitable 2 (IP: 192.168.56.102)
- Network: Host-only adapter for isolation.

## Usage
1. Make executable: `chmod +x port_scanner.sh`
2. Run: `./port_scanner.sh`
3. Output: Logs to `scan_log_YYYYMMDD.txt` with ports, services, and vuln notes.

## Lessons Learned
- Handled nc output variations with regex parsing.
- Mapped services to common Metasploit modules for recon chaining (e.g., vsftpd backdoor).
- Aligns with Security+/CEH scanning concepts.

## Future Plans
- Integrate Nmap fallback.
- Add argument parsing for custom targets/ports.

## License
MIT (see LICENSE file).
