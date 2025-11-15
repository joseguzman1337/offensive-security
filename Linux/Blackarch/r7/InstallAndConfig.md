Create CI/CD Pipelines

Automated with multiple command-line arguments and customized with Cyber Scan Ninja Techniques. That can perform various security tests and discovery functions, taking precedence over any configuration.

If you are serious about your network scanning you really should take the time to get familiar with some of them.

This research focuses on identifying the maximum batch mix mode supported by Sypder Analytics.

To do this more dynamically let's see in parallel some https://nmap.org/movies/

The main objective of this automation was designed explicitly and Limited only for educational purposes.

Only authorized Infrastructure Administrators can use these SpyderAnalitycs due to your client/target boundary concerns.

This PoC include

    Comprehensive OS guesses, Uptime, Ports, Services Device type per host detection, based on fingerprint match
    Vulnerabilities Discovery based on Network Traceroute and Services version on each port
    Host Footprinting based on TCP/IP Sequence Prediction and thumbprint over ipv4 & ipv6
    Firewall / IDS Evasion and Spoofing with accurate miscellaneous Options

2. Install neXpose

(During the installation wizard, define port 5434 for the Database):

wget http://download2.rapid7.com/download/InsightVM/Rapid7Setup-Linux64.bin && chmod +x Rapid7Setup-Linux64.bin && ./Rapid7Setup-Linux64.bin

systemctl start nexposeconsole.service

For Windows:

http://download2.rapid7.com/download/InsightVM/Rapid7Setup-Windows64.exe

Acquire the Licenses that require neXpose

https://www.rapid7.com/try/insight/ https://www.rapid7.com/try/insightvm/ https://www.rapid7.com/products/nexpose/request-download/ https://www.rapid7.com/products/insightvm/download/

    https://www.rapid7.com/products/insightvm/download/virtual-appliance/

Open Web UI https://127.0.0.1:3780 and activate your neXpose

You'll see the below message:

The Security Console is initializing, please wait... Security Console Startup Progress

InsightVM Security Console :: Security Console Configuration Rapid7 Exposure Analytics NSX Insigth VM Updated Vulnerability Coverage Edition InsightVM

Asset Exclusions, The following list of IP addresses and/or host names will be excluded from scanning across all sites:

https://kp1:3780/admin/global-settings.jsp

For create and manage settings that give a Scan Engine direct access to an NSX network of virtual assets. NSX OVF Security Console, press the Download button to update the NSX OVF distribution.

https://localhost:3780/admin/nsx-ovf.jsp

Take a coffee or a tea and w8 approx 30 minutes to proceed with the next step:

service nexposeconsole stop

systemctl disable nexposeconsole

In case that neXpose doesn't recognize your credentials, follow this:

nano /opt/rapid7/nexpose/nsc/conf/userdb.xml

And replace the content of the file with this

<Users>
<User id="nxadmin" name="nxadmin" email="" salt="39be0f50a5914aaa" passwordHash="DA5EED971969E0A7C2685F6AE52147207607A340" enabled="1">
<Roles>
<role name="nexposeadmin"/>
</Roles>
</User>
</Users>

No login again https://localhost:3780/ with "nxadmin" as username and password

Aplique los cambios a neXpose

systemctl restart nexposeconsole.service

3. Install Metasploit Pro

apt install aptitude -y && aptitude install nmap nginx postgresql -y && wget https://downloads.metasploit.com/data/releases/metasploit-latest-linux-x64-installer.run && chmod +x metasploit-latest-linux-x64-installer.run && ./metasploit-latest-linux-x64-installer.run

Open Web UI of Metasploit Pro https://localhost:3790/users/new
Initialize Metasploit Pro

If you don't see the option to create a new user, execute:

/opt/metasploit/ctlscript.sh start

service metasploit status

/opt/metasploit/createuser

Fow Windows:

http://downloads.metasploit.com/data/releases/metasploit-latest-windows-installer.exe

Acquire Metasploit Pro License

https://www.rapid7.com/try/metasploit-pro/

Activate your license at

https://localhost:1337/licenses
4. Create and save your PRO workspace

sudo -i

msfpro
db_status
db_rebuild_cache
load nexpose
load nessus
save

workspace -a sk

setg Prompt x(%whi%H/%grn%U/%whi%L%grn%D/%whi%T/%grn%W/%whiS%S/%grnJ%J)
setg ConsoleLogging y
setg LogLevel 5
setg SessionLogging y
setg TimestampOutput true
setg ExitOnSession false
pro_user root
save
exit

systemctl disable metasploit

Configure Metasploit Framework 6

(omnibus Nightly):

sudo apt install nmap -y && curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && chmod 755 msfinstall && ./msfinstall

Configure the services and database of Metasploit Framework 5:

su
msfupdate
update-rc.d postgresql enable && update-rc.d nginx enable && service postgresql start
su postgres
createuser root -P
createdb —owner=root msfdb
exit

Close terminal

Open a new terminal as a normal user, verify that services are running, and initiate the database of Metasploit Framework 6.

service --status-all

(for repair use "msfdb reinit")

It's time to open Metasploit Framework 6 (Works in Kali Linux or Ubuntu)

msfconsole

or

/opt/metasploit-framework/bin/./msfconsole

In Parrot Security:

/usr/share/metasploit-framework/./msfconsole

5. Create and Save your workspace + Update and Check Metasploit Framework 6

db_status
db_rebuild_cache
load nexpose
load nessus
save

workspace -a sk

setg Prompt x(%whi%H/%grn%U/%whi%L%grn%D/%whi%T/%grn%W/%whiS%S/%grnJ%J)
setg ConsoleLogging y
setg LogLevel 5
setg SessionLogging y
setg TimestampOutput true
setg ExitOnSession false
setg VERBOSE true
save
exit

Make a backup each time that you need of each one of your workspaces by separately

db_export -f xml /root/msfuExported.xml

Importing a file from an earlier scan (This is done using db_import followed by the path to our file.)

db_import /root/msfu/nmapScan

6. Add Vuln + Vulners + Vulscan NSE as root

Install Pre-Requisites

apt install aptitude -y && aptitude install git neofetch -y && cd /usr/share/nmap/scripts && git clone https://github.com/scipag/vulscan && git clone https://github.com/vulnersCom/nmap-vulners.git && cd vulscan/utilities/updater/ && chmod +x updateFiles.sh && ./updateFiles.sh && neofetch && cd /opt/metasploit/common/share/nmap/scripts && git clone https://github.com/scipag/vulscan && git clone https://github.com/vulnersCom/nmap-vulners.git && cd /usr/share/nmap/scripts/vulscan/utilities/updater && chmod +x updateFiles.sh && ./updateFiles.sh && cd && neofetch

For display help for the individual scripts use this option

--script-help=$scriptname

To get an easy list of the installed scripts, use

locate nse | grep nmap

Specialized Scripts to get CVE's details with Nmap & Metasploit

nmap -sY -sZ --script asn-query --script-args dns=1.1.1.1 severance.verizon.com \
-f -D RND -sV -sC --script-updatedb --script-trace -O --osscan-guess -vvv --max-retries 0 \
--min-hostgroup 7 --max-hostgroup 1337 --max-parallelism 137 --min-parallelism 2 \
--max-rtt-timeout 500ms --host-timeout 30m --randomize-hosts -sN -Pn -p- --mtu 8 \
--version-all --version-trace --reason -iL /root/SA/ad_ips \
--exclude 192.168.1.1/24 --spoof-mac 02:82:71:74:aa:32 \
-vvv -ddd -oA /root/SA/new_r7nmapScan -oS /root/SA/new_r7nmapScan_sk

The db_nmap sessions will be saved in XML so you can restart an early scan using

msfconsole
msfpro
db_nmap --resume /root/.msf4/local/file.xml

The history of Metasploit commands is here:

/root/.msf4/history

7. Create a file with the targets

cd /root && mkdir SA && cd SA && mkdir sk && cd sk && nano sk_ips

8. Create a file with the Asset Exclusions

nano bl

9. Create Metasploit Pipeline CI/CD

For Discovery with 604 NSE Scripts + CVE's Detector using MAC Spoofing

Generate a new MAC and replace the 00:00:00:00:00:00 in the below db_nmap script

macchanger eth0 -r

Generate Pipeline

nano SAD.rc

Use the script below

neofetch
workspace sk
pro_user root
workspace
spool /root/SA/new_r7nmapScan_spool
setg ExitOnSession false
setg VERBOSE true
neofetch
db_nmap --save --privileged -sY -sZ -script=auth,broadcast,brute,discovery,dos,external,fuzzer,intrusive,malware,version,vuln --script-args vulscandb=cve.csv,exploitdb.csv,openvas.csv,osvdb.csv,scipvuldb.csv,securityfocus.csv,securitytracker.csv,xforce.csv,randomseed,newtargets A -f -D RND -sV -sC --script-updatedb --script-trace -O --osscan-guess -vvv --max-retries 0 --min-hostgroup 7 --max-hostgroup 1337 --max-parallelism 137 --min-parallelism 2 --max-rtt-timeout 100ms --host-timeout 30m --randomize-hosts -sN -Pn -p- --mtu 8 --version-all --version-trace --reason -iR 10000 -PO -PM -sU -T4 -v -PE -PP -PS22,25,80 -PA21,23,80,3389 -PU40125 -PY -g 53 --traceroute --packet-trace -iL /root/SA/sk_ips --excludefile /root/SA/bl --spoof-mac 00:00:00:00:00:00 -vvv -ddd -oA /root/SA/new_r7nmapScan -oS /root/SA/new_r7nmapScan_sk
version
banner

To use your real MAC, Replace the script with this one:

Generate Pipeline

nano SAD.rc

Use the below script

neofetch
workspace sk
pro_user root
workspace
spool /root/SA/new_r7nmapScan_spool
setg ExitOnSession false
setg VERBOSE true
neofetch
db_nmap --save --privileged -sY -sZ -script=auth,broadcast,brute,discovery,dos,external,fuzzer,intrusive,malware,version,vuln --script-args vulscandb=cve.csv,exploitdb.csv,openvas.csv,osvdb.csv,scipvuldb.csv,securityfocus.csv,securitytracker.csv,xforce.csv,randomseed,newtargets A -f -D RND -sV -sC --script-updatedb --script-trace -O --osscan-guess -vvv --max-retries 0 --min-hostgroup 7 --max-hostgroup 1337 --max-parallelism 137 --min-parallelism 2 --max-rtt-timeout 100ms --host-timeout 30m --randomize-hosts -sN -Pn -p- --mtu 8 --version-all --version-trace --reason -iR 10000 -PO -PM -sU -T4 -v -PE -PP -PS22,25,80 -PA21,23,80,3389 -PU40125 -PY -g 53 --traceroute --packet-trace -iL /root/SA/sk_ips --excludefile /root/SA/bl -vvv -ddd -oA /root/SA/new_r7nmapScan -oS /root/SA/new_r7nmapScan_sk
version
banner

10. Start UltraScan with Comprehensive mode

msfconsole -r /root/SA/sk/SAD.rc

Or

msfpro

resource /root/SA/sk/SAD.rc

The monitoring log is saved in s|<rIpt kIddi3 format, at

tail -f /root/SA/sk/new_r7nmapScan_sk

For delete and old scan logs execute

rm -r /root/SA/sk/new_r7nmapScan*

rm -r /root/.msf4/local/*.*

Print host interfaces and routes (for debugging)

db_nmap --iflist

Scan Types

Fast Full Scan

db_nmap --save --privileged -sY -sZ -g 20 --script=auth,banner,broadcast,brute,default,discovery,dos,exploit,external,intrusive,malware,safe,smb-vuln-regsvc-dos.nse,version,vuln,nmap-vulners,vulscan --script-args vulscandb=cve.csv,exploitdb.csv,openvas.csv,osvdb.csv,scipvuldb.csv,securityfocus.csv,securitytracker.csv,xforce.csv,randomseed,smbbasic,smbport,smbsign,smbdomain,smbhash,smbnoguest,smbpassword,smbtype,smbusername -A -f -D RND -sV -sC --script-updatedb --script-trace -O --osscan-guess -vvv -ddd --max-retries 0 --min-hostgroup 7 --max-hostgroup 1337 --max-parallelism 137 --min-parallelism 2 --max-rtt-timeout 100ms --host-timeout 30m --randomize-hosts -sN -Pn -p443 --allports --version-all --mtu 8 --version-trace --open --reason -O --osscan-guess --traceroute --packet-trace -T4 yourdomain.com -vv -dd -oA /root/SA/sk/akmnew_r7nmapScan -oS /root/SA/sk/akmnew_r7nmapScan_sk

Default

-sS -sV -O -T4 -v --traceroute

Default, force ipv6

-sS -sV -O -T4 -v -6 --traceroute

Default, Aggressive

-A -sS -sV -O -T4 -v --traceroute

Default, base nse script

--script=default,safe -sS -sV -O -T4 -v --traceroute

Default, base nse script, force ipv6

--script=default,safe -sS -sV -O -T4 -v -6 --traceroute

Quick Scan

-T4 --traceroute

Intense scan, no ping

-T4 -A -v -Pn --traceroute

Intense scan, all TCP Ports

-T4 -A -v -PE -PS22,25,80 -PA21,23,80,3389 --traceroute

Intense scan UDP

-sS -sU -T4 -v --traceroute

For ipv6 add

-6

Specify a DNS Server

-sL --dns-server

For a slow comprehensive scan

-sS -sU -T4 -v -PE -PP -PS80,443 -PA3389 -PU40125 -PY -g 53 --traceroute

