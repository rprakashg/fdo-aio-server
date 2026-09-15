# Steps to build AMI

Overlay cloud-init packages to base image and tag the image with `aws` which we will use to spin up an EC2 instance on AWS

```sh
make cloud-init ARCH=amd64
```

```sh
podman pull quay.io/rprakashg/fdo-aio-server:aws
export IMAGE_DIGEST=$(podman inspect --format '{{.Digest}}' quay.io/rprakashg/fdo-aio-server:aws)

podman run \
    --rm \
    -it \
    --privileged \
    -v $HOME/.aws:/root/.aws:ro \
    -v ./config.toml:/config.toml:ro \
    -v ./output:/output \
    -v /var/lib/containers/storage:/var/lib/containers/storage \
    --env AWS_PROFILE=default \
    registry.redhat.io/rhel9/bootc-image-builder:latest \
    --type ami \
    --config /config.toml \
    --aws-bucket bootc-amis-demo \
    --aws-region ap-south-1 \
    --aws-ami-name fdo-aio-server \
    quay.io/rprakashg/fdo-aio-server@${IMAGE_DIGEST}
```