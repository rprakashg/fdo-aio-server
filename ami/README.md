# Steps to build AMI

Overlay cloud-init packages to base image and tag the image with `aws` which we will use to spin up an EC2 instance on AWS

```sh
make cloud-init
```

```sh
make ami
```