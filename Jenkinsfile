pipeline {
    agent any

    parameters {
        choice(
            name: 'Build-PROD',
            choices: ['prod', 'dev'],
            description: 'Which environment to build/deploy?'
        )
    }

    environment {
        APP_NAME = "pythox-x29"
        IMAGE_NAME = "pythox-x29-app"
        HOST_PORT = "${env.HOST_PORT ?: '8001'}"
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Checking out code from Git..."
                git branch: 'main',
                    credentialsId: '6251e0b1-ad19-4c4b-9c30-d4ab57b56030',
                    url: 'https://github.com/kushal-at-khalti/pythox-x29.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image... (Build-PROD = ${params['Build-PROD']})"
                sh "docker-compose build"
            }
        }

        stage('Deploy') {
            steps {
                echo "Deploying container... (Build-PROD = ${params['Build-PROD']})"
                sh "docker-compose up -d"
            }
        }

        stage('Verify') {
            steps {
                echo "Verifying deployment..."
                sh "curl -f http://localhost:${HOST_PORT}/ || (echo 'Service check failed' && exit 1)"
            }
        }
    }

    post {
        success {
            echo "Deployment successful! ${HOST_PORT}"
        }
        failure {
            echo "Deployment failed !"
        }
    }
}
