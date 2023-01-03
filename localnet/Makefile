all:
	docker build --no-cache --tag localnet/node ../.. -f evmos/Dockerfile --build-arg commit_hash=$(shell bash -c 'read -p "Version or Commit Hash: " version; echo $$version') --build-arg extra_flags=$(shell bash -c 'read -p "Extra flags: " flags; echo $$flags') --build-arg USERNAME=$$USER

# TODO: add repo flag 
# docker build --no-cache --tag localnet/node ../.. -f $(shell bash -c 'read -p "Repository: " repo; echo $$repo')/Dockerfile --build-arg commit_hash=$(shell bash -c 'read -p "Version or Commit Hash: " version; echo $$version') --build-arg extra_flags=$(shell bash -c 'read -p "Extra flags: " flags; echo $$flags')

.PHONY: all
