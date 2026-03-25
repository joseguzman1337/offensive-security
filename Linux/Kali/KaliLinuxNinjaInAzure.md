1. Deploy Debian 10 “buster” in Azure

2. Power Off the Debian 10 “buster” virtual machine

3. Expand operating system partition as you need, executing each below command in your powershell terminal

       az login
        
       az disk list --resource-group y --query '[*].{Name:name,Gb:diskSizeGb,Tier:accountType}' --output table
    
       az vm deallocate --resource-group y --name y

       az disk update --name y --resource-group y --size-gb 337

       az disk list --resource-group y --query '[*].{Name:name,Gb:diskSizeGb,Tier:accountType}' --output table

       az vm start --resource-group y --name y

    https://blogs.msdn.microsoft.com/linuxonazure/2017/04/03/how-to-resize-linux-osdisk-partition-on-azure/
    
4. Identify your operating system partition name

In my case is sda1

    df -h

5. To proceed with the partition resize, in my case I will use /dev/sda : 

       sudo fdisk /dev/sda

       type: p

this will show partition /dev/sda1

       type: d

       type: n 
        
       type: p
       
       type: 1 (to recreate partition 1) accepting the default values
        
 NOTE: if you receive a message about deleting or keeping a signature on the disk, just answer N

       type: w (to save the new partition)
        
       type: q (to exit fdisk)
        
       sudo reboot (to reboot the VM so the partition is updated)

6. To finalize the resize, Login in to the VM using SSH and execute the below command:
        
       resize2fs /dev/sda1 && sudo dmesg | grep -i sd* && df -h && read -t 5 -p "Your system will be restarted to apply the changes ..." && reboot
        
8. This script will convert your Debian 10 “buster” to a new Kali Linux Ninja in Azure

       echo "deb http://http.kali.org/kali kali-rolling main contrib non-free" >> /etc/apt/sources.list && apt-get update -y && apt-get -y --allow-unauthenticated install kali-archive-keyring && apt-cache search kali-linux && locale-gen en_US.UTF-8 && localedef -i en_US -f UTF-8 en_US.UTF-8 && export LANGUAGE=en_US.UTF-8 && export LANG=en_US.UTF-8 && export LC_ALL=en_US.UTF-8 && locale-gen en_US.UTF-8 && apt-get update -y && apt-get full-upgrade -y && apt-get install sudo wget -y && sudo apt-get autoclean && apt-get clean cache && sudo apt update && apt install kali-linux-default kali-linux-everything kali-linux-large && apt-get full-upgrade -y && apt-get full-upgrade -y && apt-get update -y && apt-get full-upgrade -y && apt-get install sudo wget -y && sudo apt-get autoclean && apt-get clean cache && sudo apt update && apt install && sudo apt-get update && sudo apt-get full-upgrade -f -y && sudo apt-get autoclean && apt-get clear cache && apt-get install software-properties-common -y && apt-get install apt-file -y && apt-file update && apt-get upgrade -y && apt autoremove -y && sudo apt-get update --fix-missing && sudo apt-get install --fix-broken && sudo apt-get autoremove && sudo apt-get update -y && apt-get install libcurl4 curl -y && sudo apt-get update && apt-get upgrade -y -f && sudo apt-get install aptitude -y && sudo aptitude safe-upgrade -y && sudo apt-get update && sudo apt-get full-upgrade -f -y && sudo dpkg --configure -a && sudo grub-mkconfig && sudo reboot
