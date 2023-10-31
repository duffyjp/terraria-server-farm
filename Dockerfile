# syntax=docker/dockerfile:1

FROM docker.io/ubuntu:latest

# Version of Terraria to use:
ENV VERSION=1449

# Download Location:
ENV DOWNLOAD="https://www.terraria.org/api/download/pc-dedicated-server/terraria-server-$VERSION.zip"

# Set the working directory in the container to /terraria
RUN mkdir -p /terraria
WORKDIR /terraria

RUN apt-get update -qq && apt-get install -y curl nano unzip golang git

# Download the Linux server files and move to the working directory
RUN curl $DOWNLOAD -o /tmp/server.zip \
 && unzip /tmp/server.zip "$VERSION/Linux/*" -d /tmp \
 && mv /tmp/$VERSION/Linux/* /terraria \
 && chmod +x TerrariaServer.bin.x86_64 \
 && echo "difficulty=0" > classic.txt \
 && echo "difficulty=1" > expert.txt \
 && echo "difficulty=2" > master.txt \
 && echo "difficulty=2\nseed=getfixedboi" > legendary.txt

# Download and compile a wrapper to provide safe SIGTERM shutdowns
RUN git clone -b debug_cpu_use_disable_autosave --single-branch https://github.com/duffyjp/TerrariaServerWrapper.git /tmp/wrapper_git
WORKDIR /tmp/wrapper_git
RUN go build -o /terraria/TerrariaServerWrapper cmd/wrapper.go
WORKDIR /terraria
