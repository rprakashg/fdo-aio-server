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
	podman build \
		--arch ${ARCH} \
		-t ${IMAGE_NAME}:${TAG} \
		.
	podman tag ${IMAGE_NAME}:${TAG} ${REGISTRY}/${IMAGE_NAME}:${TAG}

	podman push ${REGISTRY}/${IMAGE_NAME}:${TAG}