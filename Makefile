REGISTRY ?= quay.io/rprakashg
TAG ?= latest
IMAGE_NAME ?= fdo-aio-server

UNAME_M := $(shell uname -m)
ifeq ($(UNAME_M),x86_64)
  ARCH ?= amd64
else ifeq ($(UNAME_M),aarch64)
  ARCH ?= arm64
else ifeq ($(UNAME_M),arm64)
  ARCH ?= arm64
else
  ARCH ?= $(UNAME_M)
endif

.PHONY: build
build:
	echo "Building an all in one FDO server OS image"
	podman build \
		--arch ${ARCH} \
		-t ${IMAGE_NAME}:${TAG} \
		-f images/fdo-aio-server/Containerfile images/fdo-aio-server
		
	podman tag ${IMAGE_NAME}:${TAG} ${REGISTRY}/${IMAGE_NAME}:${TAG}

	podman push ${REGISTRY}/${IMAGE_NAME}:${TAG}

cloud-init:
	echo "Overlaying cloud-init packages"
	podman build \
		--arch ${ARCH} \
		-t ${REGISTRY}/${IMAGE_NAME}:aws \
		--build-arg=FROM=${REGISTRY}/${IMAGE_NAME}:${TAG} \
		-f images/cloud-init/Containerfile images/cloud-init
	
	podman push ${REGISTRY}/${IMAGE_NAME}:aws
