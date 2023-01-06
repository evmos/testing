all:
	docker build --no-cache --tag localnet/node ../.. -f Dockerfile --build-arg repo=$(shell bash -c 'read -p "Repository [evmos/ethermint]: " repo; echo $$repo') --build-arg commit_hash=$(shell bash -c 'read -p "Version or Commit Hash: " version; echo $$version') --build-arg extra_flags=$(shell bash -c 'read -p "Extra flags: " flags; echo $$flags') --build-arg USERNAME=$$USER

.PHONY: all
