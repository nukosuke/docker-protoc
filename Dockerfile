# Usage: 
#   docker run --rm -v ./protoc:/protoc nukosuke/protoc

####################
# Build Image
####################
FROM golang:1.10-alpine3.8 as build

# Install dependencies
RUN apk --update add \
  git \
  autoconf \
  automake \
  libtool \
  curl \
  make \
  g++ \
  unzip

# Build protoc
RUN git clone https://github.com/protocolbuffers/protobuf.git
WORKDIR protobuf
RUN git submodule update --init --recursive
RUN ./autogen.sh
RUN ./configure --disable-shared
RUN make
RUN make check
RUN make install

# Install protoc-gen-go
RUN go get -u github.com/golang/protobuf/protoc-gen-go


####################
# Runtime Image
####################
FROM alpine:3.8

# Copy binaries from build image
COPY --from=build /usr/local/bin/protoc /usr/bin/protoc
COPY --from=build /go/bin/protoc-gen-go /usr/bin/protoc-gen-go

CMD ['protoc', '--go_out=plugins=grpc:.', '/proto/*.proto']
