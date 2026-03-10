pipeline {
  agent {
    label "utils2"
  }
  environment {
      IMAGE_REPOSITORY = "kcr.khalti.com.np"
      ENVIRONMENT = "prod"
      PROJECT_NAME = "coredns"
      SWARM_CLUSTER_PORT = "2375"
      DC1_APP_CLUSTER_HOST = "172.17.0.120"
      DC1_APP_CLUSTER = "dc1-mgmt"
      DC2_MGMT_CLUSTER_HOST = "10.239.0.250"
      DC2_MGMT_CLUSTER = "dc2-mgmt"
      KCR_USER = credentials('KCR_USER')
      KCR_PASSWORD = credentials('KCR_PASSWORD')
  }
  parameters {
    choice(name: 'DATACENTER', choices: ['dc1', 'dc2'], description: 'Choose datacetner to deploy')
  }
  stages {  
    stage('Change docker context to default -Build Action') {
      steps {
        sh """
        docker context use default
        """
      }
    }
      
    stage('Build Docker image - Build Action') {
      steps {
        dir("${WORKSPACE}/configs/coredns") {
          script {
            Image = docker.build("${IMAGE_REPOSITORY}/opstool/${PROJECT_NAME}-${ENVIRONMENT}:${env.BUILD_ID}", "--build-arg DATACENTER=${params.DATACENTER} -f Dockerfile .")
          }
        }
      }
    }

    stage('Push Docker image - Build Action') {
      steps {
        script {
            docker.withRegistry("http://${IMAGE_REPOSITORY}", "KCR_AUTH") {
                Image.push("${env.BUILD_NUMBER}")
                Image.push("latest-${params.DATACENTER}")
            }
        }
      }
    }

    stage ('Deploy latest codes to DC1 MGMT Cluster - Deploy') {
      when {
        expression { params.DATACENTER == 'dc1' }
      }
      steps {
        dir("${WORKSPACE}/configs/coredns") {
          withCredentials(bindings: [sshUserPrivateKey(credentialsId: 'Jenkins-SSH-Key', \
                                               keyFileVariable: 'SSH_KEY', \
                                               passphraseVariable: '', \
                                               usernameVariable: '')]) {
            sh """
            docker login ${IMAGE_REPOSITORY} -u ${KCR_USER} -p ${KCR_PASSWORD} 
            docker context use ${DC1_APP_CLUSTER} || docker context create ${DC1_APP_CLUSTER} \
              --description "Docker Swarm ${DC1_APP_CLUSTER}" --docker "host=tcp://${DC1_APP_CLUSTER_HOST}:${SWARM_CLUSTER_PORT}"
            docker --context ${DC1_APP_CLUSTER} pull ${IMAGE_REPOSITORY}/opstool/${PROJECT_NAME}-${ENVIRONMENT}:latest-${params.DATACENTER}
            DATACENTER=${params.DATACENTER} docker --context ${DC1_APP_CLUSTER} stack deploy -c ./docker-compose.yml ${PROJECT_NAME}
            DATACENTER=${params.DATACENTER} docker --context ${DC1_APP_CLUSTER} service update ${PROJECT_NAME}_${PROJECT_NAME} --force
            """
          }
        }
      }
    }

    stage ('Deploy latest codes to DC2 MGMT Cluster - Deploy') {
      when {
        expression { params.DATACENTER == 'dc2' }
      }
      steps {
        dir("${WORKSPACE}/configs/coredns") {
          withCredentials(bindings: [sshUserPrivateKey(credentialsId: 'Jenkins-SSH-Key', \
                                               keyFileVariable: 'SSH_KEY', \
                                               passphraseVariable: '', \
                                               usernameVariable: '')]) {
            sh """ 
            docker login ${IMAGE_REPOSITORY} -u ${KCR_USER} -p ${KCR_PASSWORD}
            docker context use ${DC2_MGMT_CLUSTER} || docker context create ${DC2_MGMT_CLUSTER} \
              --description "Docker Swarm ${DC2_MGMT_CLUSTER}" --docker "host=tcp://${DC2_MGMT_CLUSTER_HOST}:${SWARM_CLUSTER_PORT}"
            docker --context ${DC2_MGMT_CLUSTER} pull ${IMAGE_REPOSITORY}/opstool/${PROJECT_NAME}-${ENVIRONMENT}:latest-${params.DATACENTER}
            DATACENTER=${params.DATACENTER} docker --context ${DC2_MGMT_CLUSTER} stack deploy -c ./docker-compose.yml ${PROJECT_NAME}
            DATACENTER=${params.DATACENTER} docker --context ${DC2_MGMT_CLUSTER} service update ${PROJECT_NAME}_${PROJECT_NAME} --force
            """
          }
        }
      }
    }
  }

  post {
    always {
        script {
            def changeMessages = currentBuild.changeSets.collect { changeSet ->
                changeSet.items.collect { item ->
                    "<strong>${item.author.fullName} made the following changes:</strong><br><br>${item.msg}<br>"
                }
            }.flatten().join('\n')
       
            def emailBody = "<strong>Deployment</strong><br><br><strong>Git changes:</strong><br><br>${changeMessages}"

            // Get the user who triggered the Jenkins job
            def buildCause = currentBuild.getBuildCauses()[0]
            def jobUser = buildCause.userId ?: "Unknown User" // Use a default value if user ID is not available

            // Append the line with the job user
            emailBody += "<br><strong>Job triggered by:</strong> ${jobUser}"
       
            emailext to: "t9.infra@khalti.com",
            subject: "Deployment Pipeline Running: ${currentBuild.fullDisplayName}",
            body: emailBody,
            mimeType: 'text/html', // Set the email body to HTML format
            attachLog: true
        }
    }
    aborted {
        echo 'Pipeline was aborted'
    }
    failure {
        mail to: "t9.infra@khalti.com",
        subject: "Failed Pipeline: ${currentBuild.fullDisplayName}",
        body: "Something is wrong with ${env.BUILD_URL}"
    }
  }
}