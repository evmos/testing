# evmos-perf


### Run

```bash
docker-compose up
```

To stop:

```bash
docker-compose down --volumes
```

### Customize

You can update the commits to be tested by updating `commit_hash` for `evmos-devnet1` and `evmos-devnet2` in `docker-compose.yml`.

To add more flags to evmosd start command, you can use `extra_flags` in build args of evmos devnet. For example, to add `--metrics`, you can use `extra_flags=--metrics`

### Output

Grafana: http://localhost:8000, username: admin, password: admin

Devnet1 tendermint metrics: http://localhost:26660/metrics

Devnet2 tendermint metrics: http://localhost:26661/metrics

Evmosd logs are suppressed not to spam the terminal. To check the logs, you can exec into one of the devnet container

```bash
cat /opt/evmosd.log
```

