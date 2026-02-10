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
        APP_NAME = "pythox-x29-app"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    credentialsId: '6251e0b1-ad19-4c4b-9c30-d4ab57b56030',
                    url: 'https://github.com/kushal-at-khalti/pythox-x29.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker compose build --no-cache'
            }
        }

        stage('Deploy Application') {
            steps {
                sh '''
                docker compose down || true
                docker compose up -d
                '''
            }
        }
    }

    post {
        success {
            echo " Deployment successful to ${params.ENV}!"
        }
        failure {
            echo " Deployment failed!"
        }
    }
}