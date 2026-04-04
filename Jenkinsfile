pipeline {
    agent any

    environment {
        APP_NAME = "node_app"
        APP_VERSION = "1.0.${BUILD_NUMBER}"
    }

    options {
        skipDefaultCheckout(true)
        timestamps()
    }

    stages {

        stage('Checkout') {
            steps {
                echo "🔄 Clonando código..."
                checkout([$class: 'GitSCM',
                    branches: [[name: 'main']],
                    userRemoteConfigs: [[url: 'https://github.com/lesantivanez/lab10monitoreo.git']]
                ])
            }
        }

        stage('Prepare Compose File') {
            steps {
                echo "📂 Asegurando docker-compose.yml en /app..."
                sh """
                    mkdir -p ${WORKSPACE}/app
                    if [ -f ${WORKSPACE}/docker-compose.yml ]; then
                        cp ${WORKSPACE}/docker-compose.yml ${WORKSPACE}/app/
                        echo "✅ docker-compose.yml copiado a app/"
                    elif [ -f ${WORKSPACE}/app/docker-compose.yml ]; then
                        echo "✅ docker-compose.yml ya existe en app/"
                    else
                        echo "❌ docker-compose.yml no encontrado, abortando pipeline" && exit 1
                    fi
                """
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "🐳 Construyendo imagen Docker de la app..."
                dir('app') {
                    sh "docker build -t ${APP_NAME}:${APP_VERSION} ."
                }
            }
        }

        stage('Run Tests') {
            steps {
                echo "🧪 Ejecutando tests dentro del contenedor..."
                dir('app') {
                    sh """
                    docker run --rm -w /app -e APP_VERSION=${APP_VERSION} ${APP_NAME}:${APP_VERSION} sh -c '
                        echo "📂 Contenido de /app:" && ls -la &&
                        if [ ! -f package.json ]; then
                            echo "❌ package.json no encontrado, abortando..." && exit 1
                        fi &&
                        npm test
                    '
                    """
                }
            }
        }

        stage('Deploy Monitoring Stack') {
            steps {
                echo "🚀 Desplegando Node app, Prometheus y Grafana con Docker Compose..."
                sh """
                docker run --rm \
                    -v /var/run/docker.sock:/var/run/docker.sock \
                    -v ${WORKSPACE}/app:/app \
                    -w /app \
                    docker/compose:latest -f docker-compose.yml down || true

                docker run --rm \
                    -v /var/run/docker.sock:/var/run/docker.sock \
                    -v ${WORKSPACE}/app:/app \
                    -w /app \
                    docker/compose:latest -f docker-compose.yml up -d
                """
            }
        }

        stage('Verify Deployment') {
            steps {
                echo "🔍 Verificando contenedores en ejecución..."
                sh "docker ps --filter 'name=node_app'"
                sh "docker ps --filter 'name=prometheus'"
                sh "docker ps --filter 'name=grafana'"
            }
        }

        stage('Check App Health') {
            steps {
                echo "💚 Verificando healthcheck de la app..."
                sh "docker inspect --format='{{.State.Health.Status}}' node_app || echo 'No healthcheck definido'"
            }
        }
    }

    post {
        always {
            echo "🧹 Pipeline finalizado. Los contenedores siguen corriendo."
        }
        success {
            echo "🎉 Pipeline completado correctamente! Node app + Prometheus + Grafana corriendo."
        }
        failure {
            echo "❌ Pipeline falló. Revisa los logs."
        }
    }
}