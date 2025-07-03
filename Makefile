.PHONY: help build-x86 build-arm64 push all

# Build Vars
IMAGENAME=datagenx/netshoot
VERSION=0.1

.DEFAULT_GOAL := help


build-x86: ## Build x86 image
	    @docker build --platform linux/amd64 -t ${IMAGENAME}-x86:${VERSION} .

build-arm64: ## Build arm64 image
		@docker build --platform linux/arm64 -t ${IMAGENAME}-arm64:${VERSION} .

build-all: ## Build x64/arm64 image
		@docker buildx build --platform linux/amd64,linux/arm64 --output "type=image,push=false" --file ./Dockerfile -t ${IMAGENAME}:${VERSION} -t ${IMAGENAME}:latest .

push: ## push
	 	@docker push ${IMAGENAME}:${VERSION} 
		@docker push ${IMAGENAME}:latest

all: ## all 
	@make build-all 
	@make push

help: ## show help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[$$()% a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

