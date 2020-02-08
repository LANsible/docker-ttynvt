#######################################################################################################################
# Build static libfuse
#######################################################################################################################
ARG ARCHITECTURE
FROM multiarch/alpine:${ARCHITECTURE}-v3.11 as libfuse

ENV VERSION=fuse-2.9.9

RUN apk --no-cache add \
      git \
      build-base \
      cmake \
      pkgconf \
      eudev-dev \
      libtool \
      m4 \
      gettext-dev \
      autoconf \
      automake \
      linux-headers

RUN git clone --depth 1 --branch "${VERSION}" https://github.com/libfuse/libfuse.git /libfuse

WORKDIR /libfuse

RUN CORES=$(grep -c '^processor' /proc/cpuinfo); \
    export MAKEFLAGS="-j$((CORES+1)) -l${CORES}"; \
    ./makeconf.sh && \
    ./configure && \
    make CFLAGS="-Wall -O3 -static"

#######################################################################################################################
# Build static ttnvt
#######################################################################################################################
ARG ARCHITECTURE
FROM multiarch/alpine:${ARCHITECTURE}-v3.11 as builder

ENV VERSION=master

# Add root without shell
RUN echo "root:x:0:0:root:/:" > /etc_passwd

# Install basic gcc tools
# autoconf is needed for autoreconf command
# autoreconf needs aclocal which is part of automake
RUN apk --no-cache add \
      git \
      build-base \
      openssl-dev \
      autoconf \
      automake \
      linux-headers \
      upx

RUN git clone --depth 1 --branch "${VERSION}" https://gitlab.com/lars-thrane-as/ttynvt.git /ttynvt

WORKDIR /ttynvt

# Copy header files and static library
COPY --from=libfuse /libfuse/lib/.libs/libfuse.a /lib/fuse/
COPY --from=libfuse /libfuse/include/ /usr/include/fuse/

# Work around pkg-config
ENV FUSE_CFLAGS="-I/usr/include/fuse" \
    FUSE_LIBS="-lfuse -L/lib/fuse"

# Makeflags source: https://math-linux.com/linux/tip-of-the-day/article/speedup-gnu-make-build-and-compilation-process
# -Wno-cpp is needed for:
# /usr/include/sys/poll.h:1:2: error: #warning redirecting incorrect #include <sys/poll.h> to <poll.h> [-Werror=cpp]
RUN CORES=$(grep -c '^processor' /proc/cpuinfo); \
    export MAKEFLAGS="-j$((CORES+1)) -l${CORES}"; \
    autoreconf -vif && \
    ./configure && \
    make \
      CFLAGS="-Wall -O3 -static -Wno-cpp -D_FILE_OFFSET_BITS=64"

# Minify binaries
# --brute does not work
RUN upx --best /ttynvt/src/ttynvt && \
    upx -t /ttynvt/src/ttynvt

#######################################################################################################################
# Final scratch image
#######################################################################################################################
FROM scratch

# Add description
LABEL org.label-schema.description="Static compiled ttynvt in a scratch container"

# Copy the unprivileged user
COPY --from=builder /etc_passwd /etc/passwd

# Copy static binary
COPY --from=builder /ttynvt/src/ttynvt /ttynvt

# Needs to run as since /dev/fuse is root:root
USER root
# -f run in foreground, no forking
# -E log to stdout
ENTRYPOINT ["/ttynvt", "-f", "-E"]
CMD ["--help"]
