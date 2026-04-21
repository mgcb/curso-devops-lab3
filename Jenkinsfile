pipeline {
    agent any

    environment {
        // Define any environment variables here
        // For example: 
        // MY_VAR = 'some value'
        IMAGE_NAME = 'curso-devops-lab3'
        DH_REPO = 'melco28/curso-devops-lab3'
        GHCR_REPO = 'ghcr.io/mgcb/curso-devops-lab3' // Replace with your GitHub Container Registry username
    }

    stages {
        stage('Continous Integration') {
            agent {
                docker {
                    image 'node:24'
                }
            }
            stages {
                stage('CI - Install dependencies') {
                    steps {
                        sh 'npm install'
                    }
                }
                stage('CI - lint') {
                    steps {
                        sh 'npm run lint'
                    }
                }
                stage('CI - test') {
                    steps {
                        sh 'npm run test'
                    }
                }
                stage('CI - build') {
                    steps {
                        sh 'npm run build'
                    }
                }
            }
        }
        stage('Build and Push Docker Image') {
            steps {
                var semantic = sh(
                    script: 'npm pkg get version | tr -d \'"\''
                    returnStdout: true
                    ).trim()
                script {
                    // Build the Docker image
                    sh "docker buildx build --platform linux/arm64,linux/amd64 -t ${IMAGE_NAME} ."
                    
                    docker.withRegistry('https://index.docker.io/v1/', 'jenkins-dockerhub') {
                        sh "docker tag ${IMAGE_NAME} ${DH_REPO}"
                        sh "docker tag ${IMAGE_NAME} ${DH_REPO}:${env.BUILD_NUMBER}"
                        sh "docker tag ${IMAGE_NAME} ${DH_REPO}:${semantic}"
                        sh "docker push ${DH_REPO}"
                        sh "docker push ${DH_REPO}:${env.BUILD_NUMBER}"
                        sh "docker push ${DH_REPO}:${semantic}"
                    }
                    docker.withRegistry('https://ghcr.io/v1/', 'jenkins-github') {
                        sh "docker tag ${IMAGE_NAME} ${GHCR_REPO}"
                        sh "docker tag ${IMAGE_NAME} ${GHCR_REPO}:${env.BUILD_NUMBER}"
                        sh "docker tag ${IMAGE_NAME} ${GHCR_REPO}:${semantic}"
                        sh "docker push ${GHCR_REPO}"
                        sh "docker push ${GHCR_REPO}:${env.BUILD_NUMBER}"
                        sh "docker push ${GHCR_REPO}:${semantic}"
                    }
                }
            }
        }
    }
}