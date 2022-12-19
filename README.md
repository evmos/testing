# evmos-perf

This repository contains a testing setup to inspect and compare key metrics of Evmos versions. At the moment, two Evmos nodes are started and automated bots will send transactions to both nodes.
[Prometheus](https://prometheus.io/docs/introduction/overview/) is used to create timeseries of the recorded data, while we are using [Grafana](https://grafana.com/docs/) to create interactive dashboards for inspection.

## Run

To run the testing setup, start the docker containers (defined in [docker-compose.yml](https://github.com/evmos/testing/blob/main/docker-compose.yml)) using

```bash
docker-compose up -d
```

This will run the containers in the background. If you want to see all logs immediately, omit the `-d` flag. To inspect all logs, run

```bash
docker-compose logs -f
```

To get the log outputs for individual services (e.g. the individual Evmos nodes), you can specify the service to be printed to the terminal output by adding this as an argument to the `docker compose logs` command, e.g.

```bash
docker-compose logs evmos-devnet1 -f
```

or

```bash
docker-compose logs tx-bot1 -f
```

If you want to stop the execution of the testing setup, use

```bash
docker-compose down --volumes
```

The `--volumes` flag specifies to [remove all named volumes](https://docs.docker.com/engine/reference/commandline/compose_down), which are defined in the [`volumes` section](https://github.com/evmos/testing/blob/main/docker-compose.yml#L3) in the docker-compose configuration file. 

## Customize

You can update the commits to be tested by updating `commit_hash` for `evmos-devnet1` and `evmos-devnet2` in `docker-compose.yml`.

To add more flags to evmosd start command, you can use `extra_flags` in build args of evmos devnet. For example, to add `--metrics`, you can use `extra_flags=--metrics`

## Output

To access the created Grafana dashboards, go to http://localhost:8000 while `docker compose` is running.

- Username: `admin`
- Password: `admin`

In-depth Tendermint metrics are hosted at

- devnet1: http://localhost:26660/metrics
- devnet2: http://localhost:26661/metrics
