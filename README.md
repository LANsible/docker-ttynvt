# docker-ttynvt
Dockerized version of ttnvt, RFC2217 serial to device to a local TTY device

## Run locally

Test this image locally like:
``` 
docker run -it --device /dev/cuse lansible/ttynvt:master -n ttyNVT0 -S 192.168.1.23:23
```

This should result in the /dev/ttyNVT0 port being available:
```console
# ls -l /dev/ttyNVT0
crw-rw---- 1 root dialout 241, 0 mrt 12 22:23 /dev/ttyNVT0
```
