pipeline {
    agent any

    environment {
        APP_NAME = 'node_app'
        APP_VERSION = "1.0.${BUILD_NUMBER}"
    }

    options {
        skipDefaultCheckout(true)
        timestamps()
    }

    stages {
        stage('Checkout') {
            steps {
                echo '🔄 Clonando código...'
                checkout([$class: 'GitSCM',
                    branches: [[name: 'main']],
                    userRemoteConfigs: [[url: 'https://github.com/lesantivanez/lab10monitoreo.git']]
                ])
            }
        }

        stage('Build Docker Image') {
            steps {
                echo '🐳 Construyendo imagen Docker de la app...'
                dir('app') {
                    sh "docker build -t ${APP_NAME}:${APP_VERSION} ."
                }
            }
        }

        stage('Run Tests') {
            steps {
                echo '🧪 Ejecutando tests dentro del contenedor...'
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
                echo '📂 Preparando docker-compose.yml y desplegando stack...'
                dir('app') {
                    sh '''
                    if [ ! -f docker-compose.yml ]; then
                        echo "❌ docker-compose.yml no encontrado, abortando..." && exit 1
                    fi

                    echo "📂 Contenido de app/:"
                    ls -la

                    docker-compose down -v || true
                    docker rm -f prometheus || true
                    docker volume prune -f

                    # 🔥 ESTA LÍNEA FALTABA
                    docker-compose up -d --build --force-recreate
                    '''
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                echo '🔍 Verificando contenedores en ejecución...'
                sh """
                ls -l app/prometheus_config/
                # Verificar que los contenedores existen
                docker ps --filter 'name=node_app' --format '{{.Names}}' | grep node_app || (echo '❌ node_app no está corriendo' && exit 1)
                docker ps --filter 'name=prometheus' --format '{{.Names}}' | grep prometheus || (echo '❌ Prometheus no está corriendo' && exit 1)
                docker ps --filter 'name=grafana' --format '{{.Names}}' | grep grafana || (echo '❌ Grafana no está corriendo' && exit 1)
                """
            }
        }

        stage('Validate Prometheus File') {
            steps {
                sh """
                if [ ! -f app/prometheus_config/prometheus.yml ]; then
                    echo '❌ prometheus.yml NO existe en Jenkins'
                    exit 1
                fi
                """
            }
        }

        stage('Debug Files') {
            steps {
                echo '🔍 Verificando archivos reales en Jenkins...'
                sh '''
                echo "📂 Current dir:"
                pwd
                echo "📂 Contenido de app/:"
                ls -la app
                echo "📂 Contenido de prometheus_config:"
                ls -la app/prometheus_config || echo "No existe carpeta"
                echo "📄 Ver archivo:"
                cat app/prometheus_config/prometheus.yml || echo "Archivo NO existe"
                '''
            }
        }

        stage('Check App Health') {
            steps {
                echo '💚 Verificando healthcheck de la app...'
                sh """
                docker inspect --format='{{.State.Health.Status}}' node_app || echo 'No healthcheck definido'
                """
            }
        }
    }

    post {
        always {
            echo '🧹 Pipeline finalizado. Los contenedores siguen corriendo.'
        }
        success {
            echo '🎉 Pipeline completado correctamente! Node app + Prometheus + Grafana corriendo.'
        }
        failure {
            echo '❌ Pipeline falló. Revisa los logs.'
        }
    }
}
