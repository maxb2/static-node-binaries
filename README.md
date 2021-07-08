# static-node-binaries

This provides a method of statically compiliing nodejs for multiple architectures using Alpine Linux and Docker.
Alpine Linux uses the musl library which allows for statically compiling Node.
Docker provides the means to run Alpine Linux and also to emulate multiple architectures.

## Quick-start
To produce a statically linked Linux binary on your local machine, run the following:


```
git clone https://github.com/maxb2/static-node-binaries.git
cd static-node-binaries

NODE_VERSION=v12.22.3 # Change this to the desired version
NPROCS=1              # Number of processes to use during compilation. 
                      # NPROCS=$(nproc) uses all available processors

docker build --build-arg NODE_VERSION=$NODE_VERSION --build-arg NPROCS=$NPROCS -t static-node:$NODE_VERSION .
APP=$(docker run --rm -it -d static-node:$NODE_VERSION) 
docker cp $APP:/usr/src/app/node/out/Release/node ./node-static-$NODE_VERSION
docker kill $APP
./node-static-$NODE_VERSION # Run the node binary
```
This produces the file `node-static-v12.22.3`.

## Other Architectures

We can use docker to emulate other architectures such as ARM.
The most reliable way to do this is with [`buildx`](https://github.com/docker/buildx).

### 0. Setup
Skip this step if you already have docker set up to emulate and build other architectures.
First you must [install buildx](https://github.com/docker/buildx/#installing)

```
### Setup qemu for emulation
docker run --privileged --rm tonistiigi/binfmt --install all

### Create and use buildx driver
docker buildx create --use

### List available platforms
docker buildx ls
```

### 1. Compile

```
### Set parameters
PLATFORM='linux/arm64' # Platform to emulate. Choose one from the available platforms in `docker buildx ls`
NODE_VERSION=v12.22.3  # Desired node version.
NPROCS=1               # Number of processes to use during compilation. 
                       # NPROCS=$(nproc) uses all available processors

### Compile 
docker buildx build --platform $PLATFORM --load --build-arg NODE_VERSION=$NODE_VERSION --build-arg NPROCS=$NPROCS -t static-node:$NODE_VERSION .

### Extract binary
APP=$(docker run --platform $PLATFORM --rm -it -d static-node:$NODE_VERSION) 
docker cp $APP:/usr/src/app/node/out/Release/node ./node-static-arm64-$NODE_VERSION
docker kill $APP
```

### 2. Simultaneous Compile (optional)

```
PLATFORMS='linux/amd64,linux/arm64,linux/arm/v7,linux/ppc64le,linux/s390x' # Platforms to emulate.
NODE_VERSION=v12.22.3  # Desired node version.
NPROCS=1               # Number of processes to use during compilation PER PLATFORM.

docker buildx build --platform $PLATFORMs --load --build-arg NODE_VERSION=$NODE_VERSION --build-arg NPROCS=$NPROCS -t static-node:$NODE_VERSION .
```

Then, we extract the binary for a  for a specific platform:
```
PLATFORM='linux/arm/v7'
APP=$(docker run --platform $PLATFORM --rm -it -d static-node:$NODE_VERSION) 
docker cp $APP:/usr/src/app/node/out/Release/node ./node-static-armv7-$PLATFORM-$NODE_VERSION
docker kill $APP
```