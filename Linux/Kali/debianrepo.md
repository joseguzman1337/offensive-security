    #------------------------------------------------------------------------------#
    #                   OFFICIAL cdn-fastly DEBIAN REPOS                    
    #------------------------------------------------------------------------------#

If You are not using Tails, just remove this part "tor+" from each line

```
deb [arch=amd64] tor+https://cdn-fastly.deb.debian.org/debian/ stable main contrib non-free
deb-src [arch=amd64] tor+https://cdn-fastly.deb.debian.org/debian/ stable main contrib non-free

deb [arch=amd64] tor+https://cdn-fastly.deb.debian.org/debian/ stable-updates main contrib non-free
deb-src [arch=amd64] tor+https://cdn-fastly.deb.debian.org/debian/ stable-updates main contrib non-free

deb [arch=amd64] tor+https://cdn-fastly.deb.debian.org/debian-security stable-security main contrib non-free
deb-src [arch=amd64] tor+https://cdn-fastly.deb.debian.org/debian-security stable-security main contrib non-free
```  
