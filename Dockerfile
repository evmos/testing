ARG repo="evmos"

FROM golang:1.20.2-bullseye as build-env

ARG commit_hash
ARG repo

ENV PACKAGES curl make git libc-dev bash gcc jq bc
RUN apt-get update && apt-get upgrade -y && \
  apt-get install -y $PACKAGES

WORKDIR /go/src/github.com/evmos/

WORKDIR /go/src/github.com/evmos/"$repo"
COPY ./localnet/evmosd-rocks ./build/evmosd-rocks
COPY ./localnet/evmosd-level ./build/evmosd-level
COPY ./localnet/evmosd-level-2 ./build/evmosd-level-2

# RUN git checkout ${commit_hash}

# RUN make build

RUN go install github.com/MinseokOh/toml-cli@latest

FROM ubuntu:latest as final

ARG repo
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG USERNAME
ARG extra_flags=""

# # Create a non-root user
# RUN groupadd --gid $USER_GID $USERNAME \
#     && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

WORKDIR /

RUN apt update -y && apt install jq bc -y

# Set non-root user as default user
# USER $USERNAME

# Copy over binaries from the build-env
COPY --from=build-env /go/src/github.com/evmos/"$repo"/build/"$repo"d-level .
COPY --from=build-env /go/src/github.com/evmos/"$repo"/build/"$repo"d-level-2 .
COPY --from=build-env /go/src/github.com/evmos/"$repo"/build/"$repo"d-rocks .
COPY --from=build-env /go/bin/toml-cli /usr/bin/toml-cli

COPY ./localnet/start.sh ./multi-node-start.sh
COPY ./localnet/start2.sh ./multi-node-start2.sh
COPY ./localnet/start-memiavl.sh ./multi-node-start-miavl.sh
COPY ./single-node/start.sh ./single-node-start.sh

ENV EXTRA_FLAGS=${extra_flags}
ENV CHAIN=${repo}

ENTRYPOINT ["/bin/bash", "-c"]

EXPOSE 26556
EXPOSE 26657
EXPOSE 9090
EXPOSE 1317
EXPOSE 8545
