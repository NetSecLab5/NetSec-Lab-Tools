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
- Handled nc output variations with regex parsing (e.g., "open" vs "succeeded").
- Mapped services to common Metasploit modules for recon chaining (e.g., vsftpd backdoor).
- Debugged git issues like unrelated histories for clean version control.
- Aligns with Security+/CEH scanning concepts; quantifies skills for resume (e.g., "Automated detection of 10+ vulns in lab envs").

## Script Evolution
- **Initial Version**: Basic port scanning with nc for open/closed detection and simple vuln mapping.
- **Enhancement 1**: Added Nmap fallback for resilient service fingerprinting, handling "unknown" cases from nc (reduced inaccuracies in lab tests).

## Future Plans
- Add argument parsing for custom targets/ports (e.g., using getopts for flexibility).
- Integrate Gobuster for automated web directory enumeration on detected HTTP ports.
- Expand vuln array with version-specific checks (e.g., using Nmap $version for targeted exploits).
- Add reporting: Generate Markdown summaries from logs for portfolio write-ups.

## License
MIT (see LICENSE file).
