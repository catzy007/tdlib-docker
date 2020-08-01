FROM alpine:3.9 as builder
RUN apk update
RUN apk upgrade
RUN apk add --no-cache \
    alpine-sdk \
    linux-headers \
    git \
    zlib-dev \
    openssl-dev \
    gperf \
    php \
    php-ctype \
    cmake
WORKDIR /tmp/tdlib/
RUN git clone https://github.com/tdlib/td.git /tmp/tdlib/ --branch v1.6.0
RUN mkdir build
WORKDIR /tmp/tdlib/build/
RUN export CXXFLAGS=""
RUN cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr/local ..
RUN cmake --build . --target prepare_cross_compiling
WORKDIR /tmp/tdlib/
RUN php SplitSource.php
WORKDIR /tmp/tdlib/build/
RUN cmake --build . --target install
WORKDIR /tmp/tdlib/
RUN php SplitSource.php --undo


FROM alpine:3.9
COPY --from=builder /usr/local/ /usr/local/
RUN apk add --no-cache \
    alpine-sdk \
    linux-headers \
    git \
    zlib-dev \
    openssl-dev \
    gperf \
    php \
    php-ctype \
    cmake
