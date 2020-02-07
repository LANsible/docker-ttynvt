When back to libfuse3:

```Dockerfile
# Install ninja
ADD https://github.com/ninja-build/ninja/releases/download/v1.10.0/ninja-linux.zip /usr/bin/

# See https://github.com/libfuse/libfuse
RUN mkdir build && \
    cd build && \
    meson --default-library static .. && \
    ninja
```
