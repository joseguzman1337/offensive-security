# Install azure cli in Parrot Security OS or Debian


## Add Azure Repos
```
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ stretch main" | \
     sudo tee /etc/apt/sources.list.d/azure-cli.list
```

# Install azure-cli
```
sudo apt-get update && sudo apt-get install azure-cli
```
# Login in your azure account
```
az login
```
# 
For understand what more U can do with azure cli
#
Execute this command
```
az
```
#
Welcome to the cool new Azure CLI! to display the current version execute.
#
```
az --version
```
## by C4N6
     
