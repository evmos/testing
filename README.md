# evmos-perf

This repository contains a testing setup to inspect and compare key metrics of Evmos versions. At the moment, two Evmos nodes are started and [automated bots](https://github.com/evmos/bots) will send transactions to both nodes.
[Prometheus](https://prometheus.io/docs/introduction/overview/) is used to create timeseries of the recorded data, while we are using [Grafana](https://grafana.com/docs/) to create interactive dashboards for inspection.

## Build

To build the corresponding images for the setup, run the following command

```bash
make build

# You will be prompted to select the commit hash
# for the two nodes and the repository
Version or Commit Hash for 1st node: v10.0.1
Extra flags:
Version or Commit Hash for 2nd node: v11.0.0-rc1
Extra flags:
Repository [evmos/ethermint]: evmos
```

## Run

To run the testing setup, use the command

```bash
make start
```

This will run the containers in the background. If you want to see all logs immediately, omit the `-d` flag. To inspect all logs, run

```bash
docker-compose logs -f single-node/docker-compose.yml
```

To get the log outputs for individual services (e.g. the individual Evmos nodes), you can specify the service to be printed to the terminal output by adding this as an argument to the `docker logs` command, e.g.

```bash
docker logs single-node1 -f
```

or

```bash
docker logs tx-bot1 -f
```

## Stop

If you want to stop the execution of the testing setup, use

```bash
make stop
```


## Customize

To add more flags to evmosd start command, you can use `Extra flags` prompted on the build step. For example, to add `--metrics`, you can use `Extra flags:--metrics`

## Output

To access the created Grafana dashboards, go to http://localhost:8000 while `docker compose` is running.

- Username: `admin`
- Password: `admin`

In-depth Tendermint metrics are hosted at

- devnet1: http://localhost:26660/metrics
- devnet2: http://localhost:26661/metrics

---

## Multi-node setup

To use a multi-node setup, check out the [corresponding guide](multi-node-setup.md).
