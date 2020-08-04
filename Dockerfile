FROM alpine:3.9 as builder
# installing dependency
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
# building tdlib
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
# building cpp
COPY cpp /usr/cpp
WORKDIR /usr/cpp
RUN mkdir build
WORKDIR /usr/cpp/build
RUN cmake -DCMAKE_BUILD_TYPE=Release -DTd_DIR=/usr/local ..
RUN cmake --build .


FROM alpine:3.9
COPY --from=builder /usr/local/ /usr/local/
COPY --from=builder /usr/cpp/ /usr/cpp/
RUN apk add --no-cache \
    alpine-sdk \
    linux-headers \
    git \
    zlib-dev \
    openssl-dev \
    gperf \
    php \
    php-ctype \
    cmake \
    screen
CMD screen -S session1 /usr/cpp/build/td_example
