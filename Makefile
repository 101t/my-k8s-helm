# Variables definitions
# -----------------------------------------------------------------------------

TIMEOUT ?= 60
POSTGRES_PASSWORD ?= 'postgres'
REDIS_PASSWORD ?= '123456'
HELM_DIR := helm/
TERRAFORM_DIR := terraform/
CLUSTER_NAME := test-cluster
HELM_RELEASE := my-release

all: install_deps run_terraform run_helm

# .PHONY for non-file-based targets to avoid potential naming conflicts with files.
.PHONY: install_deps run_terraform run_helm test_postgres test_redis clean

install_deps:
	@echo "Installing dependencies..."
	@sudo bash ./scripts/install_dependencies.sh

test_postgres:
	@echo "Testing PostgreSQL..."
	@sudo bash ./scripts/test_postgresql.sh

test_redis:
	@echo "Testing Redis..."
	@sudo bash ./scripts/test_redis.sh

run_terraform:
	@echo "Running Terraform to provision the cluster..."
	terraform -chdir=$(TERRAFORM_DIR) init
	terraform -chdir=$(TERRAFORM_DIR) apply -var cluster_name=$(CLUSTER_NAME) -auto-approve
	export KUBECONFIG=`terraform -chdir=$(TERRAFORM_DIR) output -raw kubeconfig`
	kind get clusters

run_helm:
	@echo "Installing Helm charts for PostgreSQL and Redis..."
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm repo update
	helm dependency update $(HELM_DIR)
	helm install $(HELM_RELEASE) $(HELM_DIR) \
	--set postgresql.global.postgresql.auth.password=$(POSTGRES_PASSWORD) \
	--set redis.auth.password=$(REDIS_PASSWORD)

clean:
	@echo "Cleaning up resources..."
	export TERRAFORM_NAME_STATE=`terraform -chdir=$(TERRAFORM_DIR) state list`
	terraform -chdir=$(TERRAFORM_DIR) state rm $(TERRAFORM_NAME_STATE)
	kind delete cluster --name $(CLUSTER_NAME)
	terraform -chdir=$(TERRAFORM_DIR) destroy -auto-approve
	helm delete $(HELM_RELEASE)
	@echo "Clean OK"
