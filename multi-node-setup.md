# Multi-node setup

We can have metrics for a multi-node setup.
At the moment, the setup comprises 5 nodes.
Make sure you have all the dependencies installed to run this setup.

## Dependencies

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docker-docs.netlify.app/compose/install/)
- Evmos binary (`evmosd`)
- [Make](https://www.gnu.org/software/make/)

> **Note**: make sure your local `evmosd` is **the same version** as the one you are testing on the setup.
> For example, if you want to test v10.0.1, check your `evmosd` version using the following command
> ```shell
>evmosd version
>10.0.1
>``` 

## Build

Build the `localnet/node` docker image running the command

```shell
make localnet-build

# user is prompted to provide the desired repository, commit hash and flags
Repository [evmos/ethermint]: evmos
Version or Commit Hash: v10.0.0-rc3
Extra flags: 
```

This will prompt for user input for 2 parameters:

- The commit hash, tag or branch of the Evmos repository to be used
- Extra build flags

The image is built based on these parameters.

## Run

Run the multi-node setup using the command

```shell
make localnet-start

# user is prompted to provide the desired repository
Repository [evmos/ethermint]: evmos
```

This will create the `localnet/build` directory where all node configurations sit.
These are used as volumes for each of the nodes.

The `genesis.json` is generated and shared among all nodes.
Then the chain starts, along with one transaction bot and the metrics infrastructure (graphana, prometheus, phlare).

Every time this command is executed, it starts a brand new chain. All previous data is deleted.

To access the Grafana dashboards go to `http://localhost:8000`.

## Stop

To stop the multi-chain setup, run

```shell
make localnet-stop
```

## Clean

You can clean all the multi-chain nodes files by running

```shell
make localnet-clean
```

This is also executed when running `make localnet-start`, so a new chain starts from scratch.
