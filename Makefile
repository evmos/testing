###############################################################################
###                                Localnet                                 ###
###############################################################################

LOCALNET_SETUP_FILE=localnet/docker-compose.yml

# Build image for a local testnet
localnet-build:
	rm -rf localnet/build*
	@$(MAKE) -C localnet

# Start a 4-node testnet locally
localnet-start: localnet-stop
	@if ! [ -f localnet/build_1/node0_1/$(EVMOS_BINARY)/config/genesis.json ]; then docker run --rm -v $(CURDIR)/localnet/build_1:/evmos:Z localnet/node1 "./evmosd testnet init-files --v 4 -o /evmos --keyring-backend=test --starting-ip-address 192.167.10.2"; fi
	@if ! [ -f localnet/build_2/node0_2/$(EVMOS_BINARY)/config/genesis.json ]; then docker run --rm -v $(CURDIR)/localnet/build_2:/evmos:Z localnet/node2 "./evmosd testnet init-files --v 4 -o /evmos --keyring-backend=test --starting-ip-address 192.167.10.2"; fi	
	docker-compose -f $(LOCALNET_SETUP_FILE) up -d

# Use this to start 4-node ethermint localnet (and comment out the code above)
# localnet-start: localnet-stop localnet-build
# 	@if ! [ -f localnet/build/node0/$(ETHERMINT_BINARY)/config/genesis.json ]; then docker run --rm -v $(CURDIR)/localnet/build:/ethermint:Z localnet/node1 "./ethermintd testnet init-files --v 4 -o /ethermint --keyring-backend=test --starting-ip-address 192.167.10.2"; fi
# 	docker-compose -f $(LOCALNET_SETUP_FILE) up -d	

# Stop testnet
localnet-stop:
	docker-compose -f $(LOCALNET_SETUP_FILE) down

# Clean testnet
localnet-clean:
	docker-compose -f $(LOCALNET_SETUP_FILE) down
	sudo rm -rf build/*

 # Reset testnet
localnet-unsafe-reset:
	docker-compose -f $(LOCALNET_SETUP_FILE) down
ifeq ($(OS),Windows_NT)
	@docker run --rm -v $(CURDIR)\localnet\build_1\node0\evmosd:/evmos\Z localnet/node1 "./evmosd tendermint unsafe-reset-all --home=/evmos"
	@docker run --rm -v $(CURDIR)\localnet\build_1\node1\evmosd:/evmos\Z localnet/node1 "./evmosd tendermint unsafe-reset-all --home=/evmos"
	@docker run --rm -v $(CURDIR)\localnet\build_1\node2\evmosd:/evmos\Z localnet/node1 "./evmosd tendermint unsafe-reset-all --home=/evmos"
	@docker run --rm -v $(CURDIR)\localnet\build_1\node3\evmosd:/evmos\Z localnet/node1 "./evmosd tendermint unsafe-reset-all --home=/evmos"
	@docker run --rm -v $(CURDIR)\localnet\build_2\node0\evmosd:/evmos\Z localnet/node2 "./evmosd tendermint unsafe-reset-all --home=/evmos"
	@docker run --rm -v $(CURDIR)\localnet\build_2\node1\evmosd:/evmos\Z localnet/node2 "./evmosd tendermint unsafe-reset-all --home=/evmos"
	@docker run --rm -v $(CURDIR)\localnet\build_2\node2\evmosd:/evmos\Z localnet/node2 "./evmosd tendermint unsafe-reset-all --home=/evmos"
	@docker run --rm -v $(CURDIR)\localnet\build_2\node3\evmosd:/evmos\Z localnet/node2 "./evmosd tendermint unsafe-reset-all --home=/evmos"	
else
	@docker run --rm -v $(CURDIR)/localnet/build_1/node0/evmosd:/evmos:Z localnet/node1 "./evmosd tendermint unsafe-reset-all --home=/evmos"
	@docker run --rm -v $(CURDIR)/localnet/build_1/node1/evmosd:/evmos:Z localnet/node1 "./evmosd tendermint unsafe-reset-all --home=/evmos"
	@docker run --rm -v $(CURDIR)/localnet/build_1/node2/evmosd:/evmos:Z localnet/node1 "./evmosd tendermint unsafe-reset-all --home=/evmos"
	@docker run --rm -v $(CURDIR)/localnet/build_1/node3/evmosd:/evmos:Z localnet/node1 "./evmosd tendermint unsafe-reset-all --home=/evmos"
	@docker run --rm -v $(CURDIR)/localnet/build_2/node0/evmosd:/evmos:Z localnet/node2 "./evmosd tendermint unsafe-reset-all --home=/evmos"
	@docker run --rm -v $(CURDIR)/localnet/build_2/node1/evmosd:/evmos:Z localnet/node2 "./evmosd tendermint unsafe-reset-all --home=/evmos"
	@docker run --rm -v $(CURDIR)/localnet/build_2/node2/evmosd:/evmos:Z localnet/node2 "./evmosd tendermint unsafe-reset-all --home=/evmos"
	@docker run --rm -v $(CURDIR)/localnet/build_2/node3/evmosd:/evmos:Z localnet/node2 "./evmosd tendermint unsafe-reset-all --home=/evmos"	
endif

# Clean testnet
localnet-show-logstream:
	docker-compose logs --tail=1000 -f

.PHONY: localnet-build localnet-start localnet-stop