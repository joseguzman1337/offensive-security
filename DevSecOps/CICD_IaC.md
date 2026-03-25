CI/CD IaC Infraestructure as Code

Deployment process: 

Basic Components= Ansible | RabbitMQ | Jenkins

In an RHEL-8 or Centos 8 VM

Install Jenkins + Java + Dev Tools + Python + RabbitMQ + Ansible following the below procedure:

***** Login in to AWS EC2 / RHEL 8 (Optional)
    
    ssh -i /root/.ssh/ec2ypcicdiac.pem ec2-user@xxx.xxx.xxx.xxx


****
```
dnf --disablerepo '*' --enablerepo extras swap centos-linux-repos centos-stream-repos
dnf distro-sync
```
```
sudo yum update -y
```

***** Install Java 8
    
    sudo yum install -y java-1.8.0-openjdk.x86_64
    sudo /usr/sbin/alternatives --set java /usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/java
    sudo /usr/sbin/alternatives --set javac /usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/javac

***** Install Jenkins

    
    sudo yum install wget -y
    sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
    sudo yum install jenkins -y
    sudo service jenkins start
    sudo service jenkins status

***** Login in to Jenkins
http://jenkins.yourdomain.org:8080/


***** Update RHEL or Centos
    
    sudo dnf update -y

***** Install Dev Tools + Python/Pip
    
    sudo dnf install python2 -y
    sudo dnf install python3 -y
    sudo dnf groupinstall 'Development Tools' -y
    sudo pip2 install argcomplete
    sudo pip3 install argcomplete
    pip2 install --user --upgrade pip
    pip3 install --user --upgrade pip

*****Install Ansible 
    
    sudo dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && sudo dnf install --enablerepo epel-playground ansible

*****Install Rabbitmq
    
    curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash
    sudo yum makecache -y --disablerepo='*' --enablerepo='rabbitmq_rabbitmq-server'
    sudo yum -y install rabbitmq-server --nobest
    rpm -qi rabbitmq-server
    echo "127.0.0.1 $(hostname -s)" | sudo tee -a /etc/hosts
    sudo systemctl enable --now rabbitmq-server.service
    systemctl status rabbitmq-server.service
    sudo rabbitmqctl status
    sudo rabbitmq-plugins enable rabbitmq_management
    ss -tunelp | grep 15672
#
    sudo rabbitmqctl add_user admin yourpassword
#
    sudo rabbitmqctl set_user_tags admin administrator
#

***** Login in to Rabbitmq
http://rabbitmq.yourdomain.org:15672/


*****Install Ansible Tower

    mkdir /tmp/tower && cd  /tmp/tower
    curl -k -O https://releases.ansible.com/ansible-tower/setup/ansible-tower-setup-latest.tar.gz
    tar xvf ansible-tower-setup-latest.tar.gz
    localectl set-locale LANG=en_US.utf8
    export LC_ALL=en_US.UTF-8
    locale
    cd ansible-tower-setup*/

Set the password for Ansible in the below file and save the changes

    nano inventory

    sudo ./setup.sh

***** Login in to Ansible Tower and request the License to Red Hat
https://ansible.yourdomain.org/portal




As optional if you like, the above tools can be automated with AWS CodeSuite | CircleCI | GitHub Actions

