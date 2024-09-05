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
        DATABASE_PASSWORD=credentials('jenkins-database-password')
        REDIS_PASSWORD=credentials('jenkins-redis-password')

        HELM_DIR=${HELM_DIR:-'./helm'}
    }
    stages {
        stage('Build Helmchart') {
            steps {
                echo "Prepare variables"
                
                sh '''
                PGPASSWORD=$(echo -n $DATABASE_PASSWORD | base64)
                RDSPASSWORD=$(echo -n $REDIS_PASSWORD | base64)
                '''.stripIndent()

                echo "Build helmchart"
                
                sh '''
                helm dependency update ${HELM_DIR}
                helm install my-release ${HELM_DIR} \
                  --set postgresql.global.postgresql.auth.password=${PGPASSWORD} \
                  --set redis.auth.password=${RDSPASSWORD}
                '''.stripIndent()

                sh 'unset PGPASSWORD'
                sh 'unset RDSPASSWORD'
            }
        }
    }
}
