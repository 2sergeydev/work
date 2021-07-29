pipeline {
    agent any
    environment {
        DOCKER_IMAGE_NAME = "serhiidevops/pet-clinic-image"
		registryCredential = "docker"
    }
    stages {
        stage('Chekout'){
            steps {
            checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/2sergeydev/work.git']]])
            }
        }
        stage('Build') {
            steps {
                echo 'Running build automation'
                sh 'ls -l'
                sh './mvnw package'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build "$DOCKER_IMAGE_NAME" + ":$BUILD_NUMBER"
                    //app = docker.build("$DOCKER_IMAGE_NAME")
                    //app.inside {
                        //sh 'echo $(curl localhost:8080)'
                
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                   // sh 'echo | set /p="Father-jntw2012" | docker login --username serhiidevops --password-stdin'
                    docker.withRegistry('https://registry.hub.docker.com', registryCredential) {
                        dockerImage.push("${env.BUILD_NUMBER}")
                        dockerImage.push("latest")
                        //app.push("${env.BUILD_NUMBER}")
                        //app.push("latest")
                    }
                }
            }
        }
        stage('Deploy To Stage-Server') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'id_cred_prod', usernameVariable: 'USERNAME', passwordVariable: 'USERPASS')]) {
                script {
                    try {
                            sh "sshpass -p '$USERPASS' ssh -o StrictHostKeyChecking=no $USERNAME@18.207.234.232 \"docker stop spring-petclinic\""
                        
                        } catch (err) {
                            echo: 'caught error: $err'
                    }
                    
                } 
                sh ''
                     sh ("sshpass -p '111111' ssh -o StrictHostKeyChecking=no sergii@18.207.234.232 \"docker run -d --rm --name spring-petclinic -p 8090:8080 $DOCKER_IMAGE_NAME:${env.BUILD_NUMBER}\"")
                }
            }
        }
    }
}
