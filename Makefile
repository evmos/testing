###############################################################################
###                                Localnet                                 ###
###############################################################################

LOCALNET_SETUP_FILE=localnet/docker-compose.yml

# Build image for a local testnet
localnet-build: localnet-clean
	@$(MAKE) -C localnet

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
