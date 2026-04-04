pipeline {
    agent any

    options {
        skipDefaultCheckout(true)
    }

    environment {
        APP_NAME = "lab10monitoreo"
        VERSION = "1.0.${BUILD_NUMBER}"
        # URL de tu repo si lo necesitas
        REPO_URL = "https://github.com/lesantivanez/lab10monitoreo.git"
        BRANCH = "main"
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

        stage('Install & Test Node App') {
            steps {
                script {
                    // Usamos docker para correr Node dentro del contenedor
                    sh """
                        docker run --rm \
                        -v \$WORKSPACE:/workspace \
                        -w /workspace/app \
                        node:18 sh -c '
                            echo "📂 Contenido de /workspace/app:" && ls -la &&
                            if [ ! -f package.json ]; then
                                echo "❌ package.json no encontrado, abortando..." && exit 1
                            fi &&
                            npm install &&
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
                        docker run --rm -d -p 3000:3000 --name ${APP_NAME}-${BUILD_NUMBER} ${APP_NAME}:${VERSION}
                        echo "✅ Contenedor levantado en localhost:3000"
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