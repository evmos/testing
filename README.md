# evmos-perf


### Run

```bash
docker-compose up -d
```

```bash
docker-compose logs -f
```

```bash
docker-compose logs evmos-devnet1 -f
```

```bash
docker-compose logs tx-bot1 -f
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
