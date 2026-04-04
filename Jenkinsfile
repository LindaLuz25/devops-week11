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

        stage('Build Docker Image') {
            steps {
                echo "🐳 Construyendo imagen Docker de la app..."
                sh "docker build -t ${APP_NAME}:${APP_VERSION} ."
            }
        }

        stage('Run Tests') {
            steps {
                echo "🧪 Ejecutando tests dentro del contenedor..."
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

        stage('Deploy Monitoring Stack') {
            steps {
                echo "🚀 Desplegando Node app, Prometheus y Grafana con Docker Compose..."
                sh """
                export APP_VERSION=${APP_VERSION}
                docker compose down || true
                docker compose up -d
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
                sh """
                docker inspect --format='{{.State.Health.Status}}' node_app || echo 'No healthcheck definido'
                """
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