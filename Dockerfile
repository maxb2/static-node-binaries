FROM alpine:3.11.3 as base
RUN apk add git python gcc g++ linux-headers make
WORKDIR /usr/src/app

FROM base as fetch
ARG NODE_VERSION=v14.17.3
RUN git clone --depth 1 https://github.com/nodejs/node --branch ${NODE_VERSION} --single-branch node

FROM fetch as configure
WORKDIR /usr/src/app/node
RUN ./configure --fully-static --enable-static

From configure as compile
ARG NPROCS=1
RUN make -j ${NPROCS}