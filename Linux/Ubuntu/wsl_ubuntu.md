# Developer Station - WSL2 Ubuntu

# What is Windows Subsystem for Linux (WSL 2) ?

Windows Subsystem for Linux (WSL 2) is a compatibility layer for running Linux binary executables natively on Windows 10. (Source: [Wikipedia](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux))

# Setup the PowerShell Environment In Windows 10 

Update/Install the AzureRM and pre-requisiste PS1 Modules. Open up a PS Window as Administrator and run:
```
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
install-module PackageManagement -verbose -force
install-module PowerShellGet -verbose -force
install-module pester -verbose -force –SkipPublisherCheck
install-module azurerm -verbose -AllowClobber
install-module azuread -verbose –AllowClobber
```

Download and Install AZ Cli from https://aka.ms/installazurecliwindows

Once completed close the PS Window.

#
## Install WSL 2

First, you need to have your Windows 10 updated to the lastest version.

Second, go to *Settings* --> *Apps* --> *Programs and Features* --> *Turn Windows features on or off* and tick the feature "*Windows Subsystem for Linux*".

Now implement WSL 2 following this https://docs.microsoft.com/en-us/windows/wsl/install-win10

Third, go to Microsoft Store search *Ubuntu* and install

#
#
#
#


## Open the Ubuntu WSL 2, Update and set your timezone
Get your WSL 2 to the latest and greatest within the version installed. Run as root:

```
apt-get update -y
apt-get upgrade -y
dpkg-reconfigure tzdata

```

## Install Ansible

There are 2 ways of installing Ansible. The preferred way is to install it from the OS repositories but this may end up unstalling a very old version (depends on multiple things on what version you get). If the Ansiuble version is to old then you can try installing it via Python's Package Manager (PIP).

Ansible Tower version is 3.2.3 and it runs Ansible version 2.4.2.

### Ansible version 2.4.2 (from OS repository)

To install the Ansible v2.4.2 run


```
echo 'deb http://ppa.launchpad.net/ansible/ansible/ubuntu zesty main' | \
     sudo tee /etc/apt/sources.list.d/ansible.list
wget -qO- 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x93C4A3FD7BB9C367' | \
     sudo apt-key add -
sudo su -c 'apt-get update && apt-get install -y ansible==2.4.2.0-1ppa~zesty && apt-mark hold ansible'
```

Keep in mind that package *ansible* is marked on hold to prevent future upgrades.

### Install Ansible + PIP 2 & 3 version by running as root:

```
apt install python-pip -y
apt install python3-pip -y
apt install ansible -y
```



### Set-up the WLS Ansible environment
#### Ansible Global Variables
On the file **_/etc/ansible/group_vars/all_**, set the variables as shown below. **It’s important you don’t include the initial “?”/question mark character provided by Azure on the SAS Tokens variables. It's also important to preserve the identation as shown below.**

```
---
ansible_env:
  IPAMURL: "url"
  SOFTWAREREPOURL: "https://<STORAGE_ACCOUNT_1_NAME>.blob.core.windows.net"
  SOFTWARESASTOKEN: "<SAS-Token 1>"
  TEMPLATEREPOURL: "https://<STORAGE_ACCOUNT_2_NAME>.blob.core.windows.net"
  TEMPLATESASTOKEN: "<SAS-Token 2>”
  ENVIROMENT: "local"
  DSCAUTOMATIONACCOUNT: "name"
  DCSAUTOMATIONKEY: "key"
  DSCAUTOMATIONURL: "url"
  MYWORKSPACEKEY: "key"
  MYWORSKPACEID: "id"
  OBJIDGROUPFOUNDATIONL3: "id"
  OBJIDGROUPENGINEERING: "id"
  OBJIDSPNANSIBLE: "id"
  AZURE_RM_SUB_australiaeast: "id"
  AZURE_RM_SUB_canadacentral: "id"
  AZURE_RM_SUB_canadaeast: "id"
  AZURE_RM_SUB_centralindia: "id"
  AZURE_RM_SUB_koreasouth: "id"
  AZURE_RM_SUB_koreasouth_mgmt: "id"
  AZURE_RM_SUB_southeastasia: "id"
  AZURE_RM_SUB_southindia: "id"
  AZURE_RM_SUB_uksouth: "id"
  AZURE_RM_SUB_uksouth_mgmt: "id"
  AZURE_RM_SUB_ukwest: "id"
  AZURE_RM_SUB_westcentralus: "id"
  AZURE_RM_SUB_westindia: "id"
  AZURE_RM_SUB_westus: "id"
  AZURE_RM_SUB_westus2: "id"
  AZURE_RM_SUB_westus2_mgmt: "id"
  AZURE_RM_SUB_eastus: "id"
  AZURE_RM_CLIENTID: "SPN_ID"
  AZURE_RM_SECRET: "SPN_SECRET"
  AZURE_RM_TENANTID: "id"
```
Make sure you replace any text bwtween **< >**a with your personal information.

#### Ansible Config file
On the file **_/etc/ansible/ansible.cfg_**, set the variables as shown below:
```
[defaults]
hash_behaviour = merge
```

Either add it to the file / default section, add the section if not present or even create the file with the content shown as above.

### Install and Set your default Azure CLI in *Ubuntu*
As root run:
```
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list
curl -L https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
apt-get install apt-transport-https -y
apt-get update && apt-get install azure-cli -y
```





### Install and Set your default Azure CLI + VS Code + .NET Core SDK 2.1 in *Ubuntu 18.04 LTS*
As root run:
```
rm -r /etc/resolv.conf
sudo systemctl disable systemd-resolved.service
sudo systemctl enable systemd-resolved.service
```

close Ubuntu

open again Ubuntu

```
sudo apt-get install dirmngr apt-transport-https
```

```
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
```

```
sudo apt-get update -y
sudo apt-get install code -y
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-bionic-prod bionic main" > /etc/apt/sources.list.d/dotnetdev.list'
sudo apt-get update -y
sudo apt-get install dotnet-sdk-2.1 -y
```

```
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
    sudo tee /etc/apt/sources.list.d/azure-cli.list
curl -L https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo apt-get update -y
sudo apt-get install azure-cli -y
sudo apt-get update && sudo apt-get upgrade
```

## Common az cli commands

» For aunthenticate in Azure cli
```
az login
```

### Example for Set an subscription as default 

```
az account list
```

```
az account set --subscription "id"
```

» For see the guide for use the azure cli
```
az --help
```

» For start an interactive session in azure cli, like Cloud Shell with autocomplete feature, using TAB key 

```
az interactive 

```



### Install PowerShell Core on WSL
As root run:
```
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
curl -o /etc/apt/sources.list.d/microsoft.list https://packages.microsoft.com/config/ubuntu/16.04/prod.list
apt-get update && apt-get install -y powershell
```

Use Power shell as a regular user by running the following command:
```
pwsh
```

### Install a Desktop graphical UI (User Interface) and RDP you need to be sure to open port 3389
As root run:
```
sudo apt-get install lxde xrdp -y
```

#Initialize xrdp
```
/etc/init.d/xrdp start
apt autoremove -y
```

You may want to also install the AzureRM's modules. Within a PowerShell prompt as root run:

```
Install-Module -Name AzureRM.Netcore
Import-Module -Name AzureRM.Netcore 
```
#
#
#
#
#
### Specially if you are behind of proxies
## Set the Proxy Server for Shell & APT Repositories  (Optional)
Edit the following files. Make sure you replace with your LDAP credentials.

you may create a config file containing proxy settings as follows:

## Set your new root password in Ubuntu
```
sudo passwd
```

## Login as root
```
sudo -su
```

```
nano /etc/apt/apt.conf.d/99proxy.conf
```

```
Acquire::http::Proxy "http://domain\samaccount:yourpassword@proxyip:8080/";
Acquire::https::Proxy "http://domain\samaccount:yourpassword@proxyip:8443/";
Acquire::ftp::Proxy "ftp://domain\samaccount:yourpassword@proxyip:8080/";
```

```
nano /etc/apt/apt.conf
```

```
Acquire::http::Proxy "http://domain\samaccount:yourpassword@proxyip:8080/";
Acquire::https::Proxy "http://domain\samaccount:yourpassword@proxyip:8443/";
Acquire::ftp::Proxy "ftp://domain\samaccount:yourpassword@proxyip:8080/";
```

```
nano /etc/apt/apt.conf.d/95proxies
```

```
Acquire::http::Proxy "http://domain\samaccount:yourpassword@proxyip:8080/";
Acquire::https::Proxy "http://domain\samaccount:yourpassword@proxyip:8443/";
Acquire::ftp::Proxy "ftp://domain\samaccount:yourpassword@proxyip:8080/";
```

```
nano ~/.bash.rc
```

```
Acquire::http::Proxy "http://domain\samaccount:yourpassword@proxyip:8080/";
Acquire::https::Proxy "http://domain\samaccount:yourpassword@proxyip:8443/";
Acquire::ftp::Proxy "ftp://domain\samaccount:yourpassword@proxyip:8080/";
```

```
nano /etc/environment
```

```
http_proxy=http://proxyip:8080/
https_proxy=http://proxyip:8080/
ftp_proxy=http://proxyip:8080/
no_proxy="localhost,127.0.0.1,youripaddress,.local.domain"
HTTP_PROXY=http://proxyip:8080/
HTTPS_PROXY=http://proxyip:8080/
FTP_PROXY=http://proxyip:8080/
NO_PROXY="localhost,127.0.0.1,youripaddress,.local.domain"
```


```
nano /etc/wgetrc 
```

(Search Proxy Section and add the below)

```
https_proxy  = http://domain\samaccount:yourpassword@proxyip:8443
http_proxy = http://domain\samaccount:yourpassword@proxyip:8080
ftp_proxy = http://domain\samaccount:yourpassword@proxyip:8080
```

Uncomment 'use_proxy = on'




```
Some valid proxies are:
```
domain (ip)
domain (ip)
```

#
#
#
#
#
#
#
## Uninstall WSL 2 (optional)

With a **_privileged user_** run on a command window:

```
lxrun /uninstall /full /y
```
