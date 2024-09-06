/*
Tarek Kalaji - 04.09.2024
*/

pipeline {
    agent any

    options {
        skipDefaultCheckout(true)
        // Keep the 10 most recent builds
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
    }

    environment {
        NAME="MY-K8S-PROJECT Pipeline"
        POSTGRES_PASSWORD=credentials('postgres-password')
        REDIS_PASSWORD=credentials('redis-password')

        ROOT_DIR=$(pwd)
        HELM_DIR=${HELM_DIR:-'./helm'}
        TERRAFORM_DIR=${TERRAFORM_DIR:-'./terraform'}
    }
    stages {
        stage('Install Dependencies') {
            steps {
                sh '''
                # Install Terraform
                if ! terraform -v > /dev/null 2>&1; then
                  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
                  sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
                  sudo apt-get update && sudo apt-get install terraform
                fi
                
                # Install Helm
                if ! helm version > /dev/null 2>&1; then
                  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
                fi

                # Installing Redis-CLI
                if ! redis-cli --version > /dev/null 2>&1; then
                  sudo apt-get update && sudo apt-get install redis-tools
                fi

                # Installing psql
                if ! psql --version > /dev/null 2>&1; then
                  sudo apt-get update && sudo apt-get install postgresql-client
                fi
                '''
            }
        }
        stage('Provision Kubernetes Cluster with Terraform') {
            steps {
                sh '''
                # Initialize and apply Terraform to create the Kind cluster
                terraform -chdir=$TERRAFORM_DIR init
                terraform -chdir=$TERRAFORM_DIR apply -auto-approve

                # Access the Cluster
                export KUBECONFIG=$(terraform -chdir=$TERRAFORM_DIR output -raw kubeconfig)
                kubectl cluster-info
                '''
            }
        }
        stage('Helmchart') {
            steps {
                // Prepare tmp variables using base64 encoding
                sh '''
                PGPASSWORD=$(echo -n $POSTGRES_PASSWORD | base64)
                RDSPASSWORD=$(echo -n $REDIS_PASSWORD | base64)
                '''.stripIndent()

                echo "Build helmchart"
                
                sh '''
                # Set up the PostgreSQL Helm chart with environment secrets and persistence enabled
                helm repo add bitnami https://charts.bitnami.com/bitnami
                helm repo update ${HELM_DIR}
                helm dependency update ${HELM_DIR}
                helm install my-release ${HELM_DIR} \
                  --set postgresql.global.postgresql.auth.password=${PGPASSWORD} \
                  --set redis.auth.password=${RDSPASSWORD}
                '''.stripIndent()

                // Destroy tmp variables
                sh 'unset PGPASSWORD'
                sh 'unset RDSPASSWORD'
            }
        }
        stage('Verify PostgreSQL and Redis') {
            steps {
                sh '''
                # Test PostgreSQL connection
                PGPASSWORD=$POSTGRES_PASSWORD psql -h <PostgreSQL External IP> -U postgres -c "SELECT version();"

                # Test Redis connection
                redis-cli -h <Redis External IP> -a $REDIS_PASSWORD ping
                '''
            }
        }
    }
}
