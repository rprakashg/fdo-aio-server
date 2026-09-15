REGISTRY ?= quay.io/rprakashg
TAG ?= latest
IMAGE_NAME ?= fdo-aio-server
ARCH ?= amd64

.PHONY: build
build:
	echo "Building an all in one FDO server OS image"
	podman build \
		--arch ${ARCH} \
		-t ${IMAGE_NAME}:${TAG} \
		-f images/fdo-aio-server/Containerfile images/fdo-aio-server
		
	podman tag ${IMAGE_NAME}:${TAG} ${REGISTRY}/${IMAGE_NAME}:${TAG}

	podman push ${REGISTRY}/${IMAGE_NAME}:${TAG}

.PHONY: cloud-init
cloud-init:
	echo "Overlaying cloud-init packages"
	podman build \
		--arch ${ARCH} \
		-t ${REGISTRY}/${IMAGE_NAME}:aws \
		--build-arg=FROM=${REGISTRY}/${IMAGE_NAME}:${TAG} \
		-f images/cloud-init/Containerfile images/cloud-init
	
	podman push ${REGISTRY}/${IMAGE_NAME}:aws

.PHONY: ami
ami:
	echo "Buildingi AMI"
	sudo podman pull quay.io/rprakashg/fdo-aio-server:aws

	sudo podman run \
		--rm \
		-it \
		--privileged \
		-v ${HOME}/.aws:/root/.aws:ro \
		-v ./ami/config.toml:/config.toml:ro \
		-v ./ami/output:/output \
		-v /var/lib/containers/storage:/var/lib/containers/storage \
		--env AWS_PROFILE=default \
		registry.redhat.io/rhel9/bootc-image-builder:latest \
		--type ami \
		--config /config.toml \
		--aws-bucket bootc-amis-demo \
		--aws-region ap-south-1 \
		--aws-ami-name fdo-aio-server \
		quay.io/rprakashg/fdo-aio-server:aws
