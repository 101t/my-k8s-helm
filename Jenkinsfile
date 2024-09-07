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
        POSTGRES_HOST='127.0.0.1'
        POSTGRES_PORT=5432
        POSTGRES_USERNAME='postgres'
        POSTGRES_PASSWORD=credentials('postgres-password')

        REDIS_HOST='127.0.0.1'
        REDIS_PORT=6379
        REDIS_PASSWORD=credentials('redis-password')

        // Directories
        SCRIPTS_DIR='./scripts'
        HELM_DIR='./helm'
        TERRAFORM_DIR='./terraform'

        RELEASE_NAME="my-release"
        CLUSTER_NAME="test-cluster"
    }
    stages {
        stage('Install Dependencies') {
            steps {
                echo 'Install Dependencies'
                sh 'bash $SCRIPTS_DIR/install_dependencies.sh'
            }
        }
        stage('Provision Kubernetes Cluster with Terraform') {
            steps {
                echo 'Initialize and apply Terraform to create the Kind cluster'
                sh '''
                terraform -chdir=$TERRAFORM_DIR init
                terraform -chdir=$TERRAFORM_DIR plan
                terraform -chdir=$TERRAFORM_DIR apply -var cluster_name=$CLUSTER_NAME -auto-approve
                '''.stripIndent()
                echo 'Access the Kind Cluster in Terraform'
                sh '''
                export KUBECONFIG=$(terraform -chdir=$TERRAFORM_DIR output -raw kubeconfig)
                # kubectl cluster-info --context $CLUSTER_NAME
                kind get clusters
                '''.stripIndent()
            }
        }
        stage('Helmchart') {
            steps {
                // Prepare variables using base64 encoding
                // sh '''
                // PG_PASSWORD=$(echo -n $POSTGRES_PASSWORD | base64)
                // REDIS_PASSWORD=$(echo -n $REDIS_PASSWORD | base64)
                // '''.stripIndent()

                echo "Build helmchart"
                
                sh '''
                # Set up the PostgreSQL Helm chart with environment secrets and persistence enabled
                helm repo add bitnami https://charts.bitnami.com/bitnami
                helm repo update $HELM_DIR
                helm dependency update $HELM_DIR
                helm install $RELEASE_NAME $HELM_DIR \
                  --set postgresql.global.postgresql.auth.password=${POSTGRES_PASSWORD} \
                  --set redis.auth.password=${REDIS_PASSWORD}
                '''.stripIndent()
            }
        }
        stage('Verify PostgreSQL and Redis') {
            steps {
                // sh '''
                // # Test PostgreSQL connection
                // PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -U $POSTGRES_USERNAME -c "SELECT version();"

                // # Test Redis connection
                // redis-cli -h $REDIS_HOST -a $REDIS_PASSWORD ping
                // '''
                echo 'Test PostgreSQL connection'
                sh 'bash $SCRIPTS_DIR/test_postgresql.sh'
                echo 'Test Redis connection'
                sh 'bash $SCRIPTS_DIR/test_redis.sh'
            }
        }
    }
    post {
        always {
            echo "Cleaning up resources..."

            // Optionally destroy the Kind cluster and any Terraform resources
            sh '''
            kind delete cluster --name $CLUSTER_NAME
            terraform -chdir=$TERRAFORM_DIR destroy -auto-approve
            '''
        }
    }
}
