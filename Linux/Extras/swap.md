
# Creando el Archivo
```
dd if=/dev/zero of=/swap bs=4096 count=4096000
```

# Make swap file
```   
mkswap /swap
```

user permission
```
chown root:disk /swap
```

#File Permission
```
chmod +600 swap
```

#Enable swap
```
swapon /swap
```
