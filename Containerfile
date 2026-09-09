FROM registry.redhat.io/rhel9/go-toolset:9.8-1788409979 AS builder

ARG REPO_URL=https://github.com/fido-device-onboard/go-fdo-server.git
ARG REPO_REF=main

WORKDIR ./go-fdo-server 

RUN git clone --branch ${REPO_REF} --depth 1 ${REPO_URL} .

RUN make build

FROM registry.redhat.io/rhel9/rhel-bootc:latest

COPY etc /etc

COPY --from=builder /opt/app-root/src/go-fdo-server/go-fdo-server /usr/bin/go-fdo-server

# Setup the directory structure
RUN mkdir -p /etc/fdo/db/ /etc/fdo/pki /etc/fdo/files

# Generate Test Certificates
# Filenames match what the fdo-manufacturing/fdo-owner/fdo-rendezvous systemd
# units (etc/systemd/system/) pass via --manufacturing-key, --device-ca-cert,
# --device-ca-key, --owner-key and --owner-cert.

# Manufacturer key (DER format)
RUN openssl ecparam -name prime256v1 -genkey -out /etc/fdo/pki/manufacturer_key.der -outform der

# Manufacturer certificate (PEM format)
RUN openssl req -x509 -key /etc/fdo/pki/manufacturer_key.der -keyform der \
  -out /etc/fdo/pki/manufacturer_cert.pem -days 365 \
  -subj "/C=US/O=Example/CN=Manufacturer"

# Device CA key (DER format)
RUN openssl ecparam -name prime256v1 -genkey -out /etc/fdo/pki/device_ca_key.der -outform der

# Device CA certificate (PEM format)
RUN openssl req -x509 -key /etc/fdo/pki/device_ca_key.der -keyform der \
  -out /etc/fdo/pki/device_ca_cert.pem -days 365 \
  -subj "/C=US/O=Example/CN=Device CA"

# Owner key (DER format)
RUN openssl ecparam -name prime256v1 -genkey -out /etc/fdo/pki/owner_key.der -outform der

# Owner certificate (PEM format)
RUN openssl req -x509 -key /etc/fdo/pki/owner_key.der -keyform der \
  -out /etc/fdo/pki/owner_cert.pem -days 365 \
  -subj "/C=US/O=Example/CN=Owner"

RUN systemctl enable fdo-manufacturing fdo-rendezvous fdo-owner

EXPOSE 8038
EXPOSE 8043
EXPOSE 8041

CMD [ "/sbin/init" ]
