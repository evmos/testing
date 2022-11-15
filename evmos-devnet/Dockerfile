FROM golang:1.19.3-bullseye as build-env

ARG commit_hash

ENV PACKAGES curl make git libc-dev bash gcc jq bc
RUN apt-get update && apt-get upgrade -y && \
  apt-get install -y $PACKAGES

WORKDIR /go/src/github.com/evmos/

RUN git clone 'https://github.com/evmos/evmos.git'

WORKDIR /go/src/github.com/evmos/evmos
RUN git checkout ${commit_hash}

RUN make build

FROM golang:1.19-bullseye as final

ARG extra_flags=""

WORKDIR /

RUN apt-get update

# Copy over binaries from the build-env
COPY --from=build-env /go/src/github.com/evmos/evmos/build/evmosd /

COPY ./start.sh ./start.sh

ENV EXTRA_FLAGS=${extra_flags}

ENTRYPOINT [ "./start.sh" ]