## Autored - Empire 

> Deploy Empire in less than 3min to the cloud using Terraform

### Setup and Deploy

1. Install terraform

2. For AWS, create an IAM and add the following to `~/.aws/credentials`
```
[autored]
aws_access_key_id = XXXXXXXXXXXXXXXX
aws_secret_access_key = YYYYYYYYYYYYYYYYYYYYYYY
region = us-east-2
```

3. In a directory on your workstation download this terraform template:
```
git clone https://github.com/sprocketsec/autored-empire
```

4. Edit variables for your infrastructure:
```
vim variables.tf
```

5. Test your config to make sure its valid (this doesnt deploy anything):
```
terraform plan
```

6. Once changes look good, deploy to AWS
```
terraform deploy
```
