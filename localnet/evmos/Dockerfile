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

ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG USERNAME
ARG extra_flags=""

# Create a non-root user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

WORKDIR /home/$USERNAME

RUN apt update -y && apt install jq bc -y

# Copy over binaries from the build-env
COPY --from=build-env /go/src/github.com/evmos/evmos/build/evmosd .

COPY ./testing/localnet/evmos/start.sh ./start.sh

ENV EXTRA_FLAGS=${extra_flags}

# Set non-root user as default user
USER $USERNAME

ENTRYPOINT ["/bin/bash", "-c"]

EXPOSE 26556
EXPOSE 26657
EXPOSE 9090
EXPOSE 1317
EXPOSE 8545
