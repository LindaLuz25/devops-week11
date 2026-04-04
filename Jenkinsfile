pipeline {
    agent any

    options {
        skipDefaultCheckout(false) // necesitamos el repo completo
        timeout(time: 20, unit: 'MINUTES')
    }

    environment {
        APP_NAME = "lab10monitoreo"
        VERSION = "1.0.${BUILD_NUMBER}"
        REPO_URL = "https://github.com/lesantivanez/lab10monitoreo.git"
        BRANCH = "main"
        APP_PORT = "3000"
    }

    stages {

        stage('Clean Workspace') {
            steps {
                deleteDir()
            }
        }

        stage('Checkout') {
            steps {
                git branch: "${BRANCH}", url: "${REPO_URL}"
            }
        }

        stage('Debug Workspace') {
            steps {
                echo "🔍 Contenido de la carpeta app:"
                sh 'ls -la $WORKSPACE/app'
            }
        }

        stage('Install & Test Node App') {
            steps {
                script {
                    sh """
                    docker run --rm \\
                        -v \$WORKSPACE/app:/app \\
                        -w /app \\
                        node:18 sh -c '
                        echo "📂 Contenido de /app:" && ls -la &&
                        if [ ! -f package.json ]; then
                            echo "❌ package.json no encontrado, abortando..." && exit 1
                        fi &&
                        echo "📦 Instalando dependencias..." &&
                        npm install &&
                        echo "🧪 Ejecutando tests..." &&
                        npm test
                    '
                    """
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                    docker build -t ${APP_NAME}:${VERSION} app/
                    """
                }
            }
        }

        stage('Run Container Locally') {
            steps {
                script {
                    sh """
                    docker run -d -p ${APP_PORT}:${APP_PORT} --name ${APP_NAME}-${BUILD_NUMBER} ${APP_NAME}:${VERSION}
                    sleep 5
                    # Health check simple
                    if curl -s http://localhost:${APP_PORT} | grep -q 'App running'; then
                        echo "✅ App corriendo correctamente en localhost:${APP_PORT}"
                    else
                        echo "❌ La app no respondió correctamente"
                        docker logs ${APP_NAME}-${BUILD_NUMBER}
                        exit 1
                    fi
                    """
                }
            }
        }

        stage('Cleanup Old Containers') {
            steps {
                script {
                    sh """
                    docker ps -a --filter "name=${APP_NAME}-" --format '{{.ID}}' | xargs -r docker rm -f
                    """
                }
            }
        }
    }

    post {
        always {
            echo "📌 Pipeline finalizado."
        }
        success {
            echo "🎉 Build y tests exitosos. Contenedor corriendo."
        }
        failure {
            echo "❌ Hubo un error en el pipeline."
        }
    }
}
}