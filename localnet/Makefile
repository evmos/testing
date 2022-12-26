all:
	docker build --no-cache --tag localnet/node1 ../.. -f evmos/Dockerfile --build-arg commit_hash=$(shell bash -c 'read -p "Version or Commit Hash for 1st chain: " version; echo $$version') --build-arg extra_flags=$(shell bash -c 'read -p "Extra flags: " flags; echo $$flags')
	docker build --no-cache --tag localnet/node2 ../.. -f evmos/Dockerfile --build-arg commit_hash=$(shell bash -c 'read -p "Version or Commit Hash for 2nd chain: " version; echo $$version') --build-arg extra_flags=$(shell bash -c 'read -p "Extra flags: " flags; echo $$flags')

# TODO add posibility to choose different repo, e.g. ethermint or evmos
# docker build --no-cache --tag localnet/node1 ../.. -f $(shell bash -c 'read -p "Repository: " repo; echo $$repo')/Dockerfile --build-arg commit_hash=$(shell bash -c 'read -p "Version or Commit Hash for 1st chain: " version; echo $$version') --build-arg extra_flags=$(shell bash -c 'read -p "Extra flags: " flags; echo $$flags')
# docker build --no-cache --tag localnet/node2 ../.. -f $(shell bash -c 'read -p "Repository: " repo; echo $$repo')/Dockerfile --build-arg commit_hash=$(shell bash -c 'read -p "Version or Commit Hash for 2nd chain: " version; echo $$version') --build-arg extra_flags=$(shell bash -c 'read -p "Extra flags: " flags; echo $$flags')
.PHONY: all
