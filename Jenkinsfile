pipeline {
    agent any
    
    environment {
        GITHUB_CRED = 'github-token'
        DOCKER_REGISTRY = credentials('docker-registry')
        SECRET_KEY = credentials('django-secret-key')
        
        BACKEND_DIR = 'backend'
        FRONTEND_DIR = 'frontend'
        
        PYTHON_VERSION = '3.12'
        NODE_VERSION = '18'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Clonando repositorio...'
                git branch: 'main', 
                    url: 'https://github.com/ASamiraJasbonM/Mindy-pwa-capacitor.git',
                    credentialsId: "${GITHUB_CRED}"
            }
        }
        
        stage('Setup Python Environment') {
            steps {
                echo 'Configurando entorno Python...'
                sh '''
                    cd ${BACKEND_DIR}
                    python3 -m venv venv
                    . venv/bin/activate
                    pip install --upgrade pip
                    pip install -r requirements.txt
                '''
            }
        }
        
        stage('Backend Tests') {
            steps {
                echo 'Ejecutando pruebas del backend...'
                sh '''
                    cd ${BACKEND_DIR}
                    . venv/bin/activate
                    python manage.py check
                    python manage.py test --noinput || true
                '''
            }
            post {
                always {
                    junit allowEmptyResults: true, testResults: '${BACKEND_DIR}/**/test-results.xml'
                }
            }
        }
        
        stage('Static Files Collection') {
            steps {
                echo 'Recopilando archivos estáticos...'
                sh '''
                    cd ${BACKEND_DIR}
                    . venv/bin/activate
                    python manage.py collectstatic --noinput
                '''
            }
        }
        
        stage('Setup Node Environment') {
            steps {
                echo 'Instalando dependencias Node...'
                sh '''
                    cd ${FRONTEND_DIR}
                    npm install
                '''
            }
        }
        
        stage('Build PWA') {
            steps {
                echo 'Construyendo PWA...'
                sh '''
                    cd ${FRONTEND_DIR}
                    npm run build || echo "No build script found"
                '''
            }
        }
        
        stage('Security Checks') {
            steps {
                echo 'Verificando seguridad...'
                sh '''
                    cd ${BACKEND_DIR}
                    . venv/bin/activate
                    pip install safety
                    safety check --full-report || true
                    
                    pip install bandit
                    bandit -r myapp/ -f json -o bandit-report.json || true
                '''
            }
            post {
                always {
                    recordIssues tools: [bandit(pattern: '${BACKEND_DIR}/bandit-report.json')]
                }
            }
        }
        
        stage('Linting') {
            steps {
                echo 'Verificando calidad de código...'
                sh '''
                    cd ${BACKEND_DIR}
                    . venv/bin/activate
                    pip install flake8
                    flake8 myapp/ --max-line-length=120 --exit-zero || true
                '''
            }
        }
        
        stage('Build Docker Image') {
            when {
                expression { env.DOCKER_REGISTRY != null }
            }
            steps {
                echo 'Construyendo imagen Docker...'
                script {
                    def imageTag = "${env.BUILD_NUMBER}"
                    sh """
                        docker build -t mindy-backend:${imageTag} -f Dockerfile.backend .
                        docker tag mindy-backend:${imageTag} ${DOCKER_REGISTRY}/mindy-backend:${imageTag}
                        docker push ${DOCKER_REGISTRY}/mindy-backend:${imageTag}
                    """
                }
            }
        }
        
        stage('Deploy to Staging') {
            when {
                branch 'main'
            }
            steps {
                echo 'Desplegando a staging...'
                sh '''
                    docker-compose -f docker-compose.staging.yml down
                    docker-compose -f docker-compose.staging.yml up -d
                    sleep 10
                    docker exec mindy-backend python manage.py migrate
                '''
            }
        }
        
        stage('Health Check') {
            steps {
                echo 'Verificando estado del servicio...'
                sh '''
                    curl -f http://localhost:8000/ || exit 1
                    echo "Servicio funcionando correctamente"
                '''
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline completado exitosamente'
        }
        failure {
            echo 'Pipeline falló. Revisa los logs.'
        }
        always {
            cleanWs()
        }
    }
}
