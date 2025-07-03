
# Build Vars
IMAGENAME="datagenx/netshoot"
SHA_VERSION="$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)"
VERSION="$(shell git describe --tags --abbrev=0)"

.DEFAULT_GOAL := build-x86

clean:
	rm -rf build/bin/

multi-build:
	@docker buildx create --use --platform=linux/arm64,linux/amd64 --name multi-platform-builder
	@docker buildx inspect --bootstrap

build-x86:
		@echo "VERSION: ${VERSION}"
	    @docker buildx build --platform linux/amd64 \
		--output "type=docker,push=false" \
		-t ${IMAGENAME}-amd64:${SHA_VERSION} \
		-t ${IMAGENAME}-amd64:${VERSION} \
		-t ${IMAGENAME}-amd64:latest \
		-t ${IMAGENAME}:latest \
		.

build-arm64:
		@echo "VERSION: ${VERSION}"
		@docker buildx build --platform linux/arm64 \
		--output "type=docker,push=false" \
		-t ${IMAGENAME}-arm64:${SHA_VERSION} \
		-t ${IMAGENAME}-arm64:${VERSION} \
		-t ${IMAGENAME}-arm64:latest \
		.

build-all:
#		@make multi-build
		@docker buildx build --platform linux/amd64,linux/arm64 \
		--output "type=image,push=false" \
		--file ./Dockerfile .

push:
	 	@docker push ${IMAGENAME}:${VERSION} 

all: build-all push