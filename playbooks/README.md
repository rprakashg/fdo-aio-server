# Provisioning
Provisioning an instance of all in one FDO server on AWS

Values to update in [params.yaml](./vars/params.yaml)

| Variable Name | Notes |
| ------------- | ----- |
| ami_id | AMI ID from AWS |
| subnet_id | Subnet ID from AWS |
| security_group_id | Security Group ID from AWS |

Generate a device  enrollment certificate

```sh
flightctl certificate \
    request \
    --signer=enrollment \
    --expiration=365d \
    --output=embedded > config.yaml
```

To provision an instance run the launch instance playbook

```sh
ansible-playbook --vault-password-file <(echo "$VAULT_SECRET") launch_instance.yaml -e @vars/params.yaml
```