# learning stack

```sh
terraform init
terraform validate
terraform plan -out plan.out -var="registry_password=ghp_XXXXXXXXXX"
terraform apply plan.out
```