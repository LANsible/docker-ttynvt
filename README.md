# docker-ttynvt
Dockerized version of ttnvt, RFC2217 serial to device to a local TTY device

## Requirements

This requires a kernel compiled with the [CUSE](https://cateee.net/lkddb/web-lkddb/CUSE.html) enabled, you can check this by running:

```
cat /boot/config-* | grep CONFIG_CUSE
```
This should return `CONFIG_CUSE=m` or `CONFIG_CUSE=y` otherwise this container isn't working for you.

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

## Credits

* [lars-thrane-as/ttynvt](https://gitlab.com/lars-thrane-as/ttynvt)
