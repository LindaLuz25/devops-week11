pipeline {
    agent any

    environment {
        APP_NAME = "node_app"
        APP_VERSION = "1.0.${BUILD_NUMBER}"
        APP_DIR = "app"
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
                dir("${APP_DIR}") {
                    sh "docker build -t ${APP_NAME}:${APP_VERSION} ."
                }
            }
        }

        stage('Run Tests') {
            steps {
                echo "🧪 Ejecutando tests dentro del contenedor..."
                dir("${APP_DIR}") {
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
                echo "🚀 Desplegando Node app, Prometheus y Grafana con Docker Compose en contenedor..."
                dir("${APP_DIR}") {
                    sh """
                    docker run --rm \
                        -v /var/run/docker.sock:/var/run/docker.sock \
                        -v ${WORKSPACE}/app:/app -w /app \
                        docker/compose:latest down || true

                    docker run --rm \
                        -v /var/run/docker.sock:/var/run/docker.sock \
                        -v ${WORKSPACE}/app:/app -w /app \
                        docker/compose:latest up -d
                    """
                }
            }
        }

        stage('Wait for Node App') {
            steps {
                echo "⏳ Esperando que la app Node esté lista..."
                timeout(time: 30, unit: 'SECONDS') {
                    waitUntil {
                        script {
                            def status = sh(script: 'curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 || true', returnStdout: true).trim()
                            return status == "200"
                        }
                    }
                }
            }
        }

        stage('Verify Monitoring Services') {
            steps {
                echo "🔍 Verificando servicios Node, Prometheus y Grafana..."
                dir("${APP_DIR}") {
                    sh '''
                    echo "Node App:" && curl -s -I http://localhost:3000 | head -n 1
                    echo "Prometheus:" && curl -s -I http://localhost:9090 | head -n 1
                    echo "Grafana:" && curl -s -I http://localhost:3001 | head -n 1
                    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v ${WORKSPACE}/app:/app -w /app docker/compose:latest ps
                    '''
                }
            }
        }

        stage('Check App Health') {
            steps {
                echo "💚 Verificando healthcheck de Node app..."
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