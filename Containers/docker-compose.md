# Upgrade docker-compose to 2.23.0 version

At the moment the safest way to upgrade docker-compose to last release as root

```ShellSession
sudo -i
```

# Is by deleting it and reinstalling it
```ShellSession
sudo rm /usr/bin/docker-compose 
```

```ShellSession
curl -L https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-linux-x86_64 > /usr/bin/docker-compose && chmod +x /usr/bin/docker-compose && docker-compose --version
```
