FROM debian as base
RUN apt update && apt install build-essential make git
WORKDIR /usr/src/app

FROM base as fetch
ARG NODE_VERSION=v16.5.0
RUN if [ "${NODE_VERSION:0:3}" = v12 ]; then apt install python2; else apt install python3; fi
RUN git clone --depth 1 https://github.com/nodejs/node --branch ${NODE_VERSION} --single-branch node

FROM fetch as configure
WORKDIR /usr/src/app/node
RUN ./configure --partly-static $([ $(uname -m) = armv7l ] && echo --openssl-no-asm)

FROM configure as compile
ARG NPROCS=1
RUN make -j ${NPROCS}

FROM compile as test
RUN make test
