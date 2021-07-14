FROM alpine:3.14.0 as base
RUN apk add git gcc g++ linux-headers make
WORKDIR /usr/src/app

FROM base as fetch
ARG NODE_VERSION=v16.4.2
RUN if [ "${NODE_VERSION:0:3}" = v12 ]; then apk add python2; else apk add python3; fi
RUN git clone --depth 1 https://github.com/nodejs/node --branch ${NODE_VERSION} --single-branch node

FROM fetch as configure
WORKDIR /usr/src/app/node
RUN if [ $(uname -m) = armv7l ]; then ./configure --fully-static --enable-static --openssl-no-asm; else ./configure --fully-static --enable-static; fi

FROM configure as compile
ARG NPROCS=1
RUN make -j ${NPROCS}

FROM compile as test
RUN make test