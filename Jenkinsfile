pipeline {
    agent any

    environment {
        APP_NAME = "pythox-x29-app"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    credentialsId: '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',  // Jenkins credentials
                    url: 'https://github.com/YOUR-GITHUB-USER/pythox-x29.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker compose build'
            }
        }

        stage('Deploy Application') {
            steps {
                sh '''
                docker compose down
                docker compose up -d
                '''
            }
        }
    }

    post {
        success {
            echo " Deployment successful!"
        }
        failure {
            echo " Deployment failed!"
        }
    }
}
