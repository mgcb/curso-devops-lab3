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
                script {
                    // Build the Docker image
                    sh "docker build -t ${IMAGE_NAME} ."
                }
            }
        }
    }
}