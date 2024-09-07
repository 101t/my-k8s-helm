MY-K8S-PROJECT 
==============

### Table of Content
1. [Getting Started](#getting-started)
2. [Working on Terraform](#working-on-terraform)
3. [Working on Helmchart](#working-on-helmchart)
4. [Running Tests](#running-tests)

## Getting Started
Install all required dependencies
```sh
sudo bash ./scripts/install_dependencies.sh
```

## Working on Terraform:
To download terraform providers
```sh
terraform -chdir=terraform/ init
```
To show the terraform will want to deploy
```sh
terraform -chdir=terraform/ plan
```
To have a clustor deployed
```sh
terraform -chdir=terraform/ apply -auto-approve
```
To access terraform cluster via `kubectl`
```sh
export KUBECONFIG=$(terraform -chdir=$TERRAFORM_DIR output -raw kubeconfig)
```
Checking cluster
```sh
kubectl cluster-info --context test-cluster
```
You may check cluster name via `kind`
```sh
kind get clusters
````
To tear down cluster
```sh
terraform -chdir=terraform/ destroy -auto-approve
```
## Working on Helmchart
add `bitnami` repository to helmchart
```sh
helm repo add bitnami https://charts.bitnami.com/bitnami
```
Update repositories
```sh
helm repo update helm/
```
Update dependencies
```sh
helm depedependency update helm/
```
To run databases cluster via `helm`
```sh
helm install mymy-release helm/ \
--set postgresql.global.postgresql.auth.password=${POSTGRES_PASSWORD} \
--set redis.auth.password=${REDIS_PASSWORD}
```
## Running Tests
To test PostgreSQL connection
```sh
sudo bash ./scripts/test_postgresql.sh
```
To test RedisDB connection
```sh
sudo bash ./scripts/test_redis.sh
```
