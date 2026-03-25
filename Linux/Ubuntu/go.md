```bash
cd ~/Downloads && wget https://dl.google.com/go/go1.23.4.linux-amd64.tar.gz && sudo rm -rf /usr/bin/go && sudo tar -C /usr/bin/ -xzf go1.23.4.linux-amd64.tar.gz && sudo chmod +x /usr/bin/go/bin/go && export PATH=$PATH:/usr/bin/go/bin && go version
```
