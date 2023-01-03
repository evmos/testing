###############################################################################
###                                Localnet                                 ###
###############################################################################

LOCALNET_SETUP_FILE=localnet/docker-compose.yml

# Build image for a local testnet
localnet-build: localnet-clean
	@$(MAKE) -C localnet

# Start a 4-node testnet locally
localnet-start: localnet-clean
	@if ! [ -f localnet/build/node0/$(EVMOS_BINARY)/config/genesis.json ]; then docker run --rm -v $(CURDIR)/localnet/build:/evmos:Z localnet/node "./evmosd testnet init-files --v 4 -o /evmos --keyring-backend=test --starting-ip-address 192.167.10.2 --chain-id evmos_9999-1"; fi
	localnet/evmos/setup_genesis.sh
	docker-compose -f $(LOCALNET_SETUP_FILE) up -d

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

# Clean testnet
localnet-show-logstream:
	docker-compose logs --tail=1000 -f

.PHONY: localnet-build localnet-start localnet-stop