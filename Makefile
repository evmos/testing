###############################################################################
###                               Single-node                               ###
###############################################################################

SINGLE_NODE_SETUP_FILE=single-node/docker-compose.yml

build: stop
	@while [ -z "$$REPO" ]; do \
    read -r -p "Repository [evmos/ethermint]: " REPO; \
	done; \
    if [ $$REPO != "evmos" ] && [ $$REPO != "ethermint" ]; \
	then \
		echo "Invalid repo. Using default (evmos)"; \
		REPO=evmos; \
	fi; \
	echo "Building single-node setup with $$REPO ..."; \
	docker build --no-cache --tag single-node1 .  --build-arg repo=$$REPO --build-arg commit_hash=$(shell bash -c 'read -p "Version or Commit Hash for 1st node: " version; echo $$version') --build-arg extra_flags=$(shell bash -c 'read -p "Extra flags: " flags; echo $$flags') --build-arg USERNAME=$$USER; \
	docker build --no-cache --tag single-node2 .  --build-arg repo=$$REPO --build-arg commit_hash=$(shell bash -c 'read -p "Version or Commit Hash for 2nd node: " version; echo $$version') --build-arg extra_flags=$(shell bash -c 'read -p "Extra flags: " flags; echo $$flags') --build-arg USERNAME=$$USER; \

start: stop
	docker-compose -f $(SINGLE_NODE_SETUP_FILE) up --build -d

stop:
	docker-compose -f $(SINGLE_NODE_SETUP_FILE) down -v	

###############################################################################
###                                Localnet                                 ###
###############################################################################

LOCALNET_SETUP_FILE=localnet/docker-compose.yml

# Build image for a local testnet
localnet-build: localnet-clean
	docker build --no-cache --tag localnet/node .  --build-arg repo=$(shell bash -c 'read -p "Repository [evmos/ethermint]: " repo; echo $$repo') --build-arg commit_hash=$(shell bash -c 'read -p "Version or Commit Hash: " version; echo $$version') --build-arg extra_flags=$(shell bash -c 'read -p "Extra flags: " flags; echo $$flags') --build-arg USERNAME=$$USER

# Start a 5-node testnet locally
localnet-start: localnet-clean 
	@while [ -z "$$REPO" ]; do \
    read -r -p "Repository [evmos/ethermint]: " REPO; \
    done ; \
    if [ $$REPO != "evmos" ] && [ $$REPO != "ethermint" ]; \
	then \
		echo "Invalid repo. Using default (evmos)"; \
		REPO=evmos; \
	fi; \
	echo "Starting multi-node setup with $$REPO ..."; \
	bin="$$REPO"d; \
	chainID="$$REPO"_9999-1; \
	mkdir localnet/build; \
	docker run --rm -v $(CURDIR)/localnet/build:/$$REPO:Z localnet/node "./"$$bin" testnet init-files --v 4 -o /"$$REPO" --keyring-backend=test --starting-ip-address 192.167.10.2 --chain-id "$$chainID""; \
	CHAIN=$$REPO localnet/setup_genesis.sh; \
	docker-compose -f $(LOCALNET_SETUP_FILE) up -d;

# Stop testnet
localnet-stop:
	docker-compose -f $(LOCALNET_SETUP_FILE) down

# Clean testnet
localnet-clean: localnet-stop
	rm -rf localnet/build*

 # Reset testnet
localnet-unsafe-reset:
	docker-compose -f $(LOCALNET_SETUP_FILE) down
ifeq ($(OS),Windows_NT)
	@docker run --rm -v $(CURDIR)\build\node0\evmosd:/evmos\Z localnet/node "./evmosd tendermint unsafe-reset-all --home=/evmos"
	@docker run --rm -v $(CURDIR)\build\node1\evmosd:/evmos\Z localnet/node "./evmosd tendermint unsafe-reset-all --home=/evmos"
	@docker run --rm -v $(CURDIR)\build\node2\evmosd:/evmos\Z localnet/node "./evmosd tendermint unsafe-reset-all --home=/evmos"
	@docker run --rm -v $(CURDIR)\build\node3\evmosd:/evmos\Z localnet/node "./evmosd tendermint unsafe-reset-all --home=/evmos"
else
	@docker run --rm -v $(CURDIR)/build/node0/evmosd:/evmos:Z localnet/node "./evmosd tendermint unsafe-reset-all --home=/evmos"
	@docker run --rm -v $(CURDIR)/build/node1/evmosd:/evmos:Z localnet/node "./evmosd tendermint unsafe-reset-all --home=/evmos"
	@docker run --rm -v $(CURDIR)/build/node2/evmosd:/evmos:Z localnet/node "./evmosd tendermint unsafe-reset-all --home=/evmos"
	@docker run --rm -v $(CURDIR)/build/node3/evmosd:/evmos:Z localnet/node "./evmosd tendermint unsafe-reset-all --home=/evmos"
endif

# Show stream of logs
localnet-show-logstream:
	docker-compose logs --tail=1000 -f

.PHONY: localnet-build localnet-start localnet-stop
