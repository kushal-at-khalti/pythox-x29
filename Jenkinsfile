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
                    credentialsId: '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',
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