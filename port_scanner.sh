#!/bin/bash
TARGET="192.168.56.102"
PORTS="21 22 25 53 80 111 139 445 512 513 514 1099 1524 2049 2121 3306 5432 5900 6000 6667 8009 8180"  # Your list; add/remove for your lab
LOGFILE="scan_log_$(date +%Y%m%d).txt"

# Associative array for service-based vulns (high-level from Metasploitable 2 guides)
declare -A vuln_info
vuln_info["ftp"]="Vulnerability: vsftpd 2.3.4 backdoor\nMetasploit Module: exploit/unix/ftp/vsftpd_234_backdoor\nAccess: Root shell"
vuln_info["ircd"]="Vulnerability: UnrealIRCd 3.2.8.1 backdoor\nMetasploit Module: exploit/unix/irc/unreal_ircd_3281_backdoor\nAccess: Root shell"
vuln_info["ingreslock"]="Vulnerability: Ingreslock backdoor\nAccess: Root shell (manual bind shell)"
vuln_info["nfs"]="Vulnerability: Writeable NFS export\nAccess: Root filesystem access (e.g., via mount and SSH key injection)"
vuln_info["mysql"]="Vulnerability: Open MySQL root access (no password)\nAccess: Database root privileges"
vuln_info["postgresql"]="Vulnerability: Weak PostgreSQL credentials (postgres:postgres)\nAccess: Database access as postgres user"
vuln_info["http"]="Vulnerability: Multiple web app flaws (e.g., SQLi, command injection in DVWA, Mutillidae, phpMyAdmin)\nAccess: Code execution, data disclosure"
vuln_info["netbios-ssn"]="Vulnerability: Samba symlink traversal and weak shares\nMetasploit Module: auxiliary/admin/smb/samba_symlink_traversal\nAccess: Root filesystem access"
vuln_info["microsoft-ds"]="${vuln_info[netbios-ssn]}"  # Same as above for Samba
vuln_info["exec"]="Vulnerability: r-services misconfig (.rhosts)\nAccess: Remote shell (requires rsh-client)"
vuln_info["login"]="${vuln_info[exec]}"  # Grouped r-services
vuln_info["shell"]="${vuln_info[exec]}"  # Grouped r-services

# Port-based fallbacks for unknown services (e.g., ?)
declare -A port_vuln
port_vuln["5900"]="Vulnerability: VNC weak password (password)\nAccess: Remote desktop access"

# Input validation
if ! ping -c1 $TARGET &>/dev/null; then
    echo "Target $TARGET unreachable—check network/VM status." | tee $LOGFILE
    exit 1
fi

echo "Starting scan on $TARGET at $(date)" > $LOGFILE
echo "" >> $LOGFILE  # Spacer

for port in $PORTS; do
    output=$(nc -zv $TARGET $port 2>&1)
    cleaned_output=$(echo "$output" | grep -v "inverse host lookup failed")
    if echo "$output" | grep -iqE "succeeded|open"; then
        result="OPEN"
        # Fixed service parse: Grab the correct field (e.g., "ftp" from second parentheses)
        service=$(echo "$cleaned_output" | awk -F '[()]' '/open|succeeded/ { if (NF >= 4) print $4; else print "unknown" }' | sed 's/ //g' | head -1)  # Trim spaces
        if [ "$service" = "?" ] || [ -z "$service" ]; then service="unknown"; fi

        if [ "$service" = "unknown" ]; then
            nmap_output=$(sudo nmap -sV -p $port $TARGET 2>&1 | grep "^$port" | awk '{print $4 " " $5 " " $6}' | sed 's/ //g')
            service=$(echo "$nmap_output" | awk '{print $1}')  # e.g., "ssh"
            version=$(echo "$nmap_output" | awk '{print $2 " " $3}')  # e.g., "OpenSSH 4.7p1"
            echo "Fallback Nmap detected: $service $version" >> $LOGFILE
        fi

        echo "$port: $result ($service)" >> $LOGFILE
        
        # Add exploits if available (service first, then port fallback)
        if [ -n "${vuln_info[$service]}" ]; then
            echo "Possible Metasploit exploits and access:" >> $LOGFILE
            echo -e "${vuln_info[$service]}" | sed 's/^/  - /g' >> $LOGFILE  # Bullet indent
            echo "" >> $LOGFILE  # Spacer
        elif [ -n "${port_vuln[$port]}" ]; then
            echo "Possible Metasploit exploits and access:" >> $LOGFILE
            echo -e "${port_vuln[$port]}" | sed 's/^/  - /g' >> $LOGFILE
            echo "" >> $LOGFILE
        fi
    else
        result="CLOSED/FILTERED"
        echo "$port: $result" >> $LOGFILE
    fi
done

echo "" >> $LOGFILE
echo "Scan complete. Open ports summary:" >> $LOGFILE
grep "OPEN" $LOGFILE | awk '{print "  - " $0}' >> $LOGFILE  # Bulleted summary

echo "Scan logged to $LOGFILE"  # Console feedback
