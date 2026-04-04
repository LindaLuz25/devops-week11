pipeline {

    agent any

    environment {
        APP_NAME = "lab10monitoreo"
        VERSION = "1.0.${BUILD_NUMBER}"
        REPO_URL = "https://github.com/lesantivanez/lab10monitoreo.git"
        BRANCH = "main"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: "${BRANCH}", url: "${REPO_URL}"
            }
        }

        stage('Install & Test') {
            steps {
                sh '''
                docker run --rm \
                  -v $WORKSPACE:/app \
                  -w /app/app \
                  node:18 \
                  sh -c "npm install && npm test"
                '''
            }
        }

        stage('Build Image') {
            steps {
                sh "docker build -t ${APP_NAME}:${VERSION} ."
            }
        }

        stage('Deploy') {
            steps {
                sh 'docker compose down || true'
                sh "APP_VERSION=${VERSION} docker compose up -d --build"
            }
        }

        stage('Health Check') {
            steps {
                sh '''
                sleep 5
                curl -f http://localhost:3000
                '''
            }
        }
    }
}