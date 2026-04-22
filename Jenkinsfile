pipeline {
    agent any

    environment {
        // Define any environment variables here
        // For example: 
        // MY_VAR = 'some value'
        IMAGE_NAME = 'curso-devops-lab3'
        DH_REPO = 'melco28/curso-devops-lab3'
        GHCR_REPO = 'ghcr.io/mgcb/curso-devops-lab3'
        DEPLOYMENT_NAME = 'curso-devops-lab3-deployment'
        CONTAINER_NAME = 'curso-devops-lab3'
        NAMESPACE = 'mcorletto'

    }

    stages {
        stage('Continous Integration') {
            agent {
                docker {
                    image 'node:24'
                }
            }
            stages {
                stage('CI - Set semantic version') {
                    steps {
                        script {
                            env.SEMANTIC_VERSION = sh(
                                script: 'npm pkg get version | tr -d \'"\'', returnStdout: true
                            ).trim()
                        }
                    }
                }
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
                        sh 'npm run test:cov'
                    }
                }
                stage('CI - build') {
                    steps {
                        sh 'npm run build'
                    }
                }
            }
        }
        stage('Quality Assurance') {
            agent {
                docker {
                    image 'sonarsource/sonar-scanner-cli:latest'
                    args '--network=devops-infra_default'
                    reuseNode true
                }
            }
            stages {
                stage('QA - Code Analysis') {
                    steps {
                        script {
                            withSonarQubeEnv('sonarqube') {
                                sh 'sonar-scanner'
                            }
                        }
                    }
                }
                stage('QA - Quality Gate') {
                    steps {
                        script {
                            def qualityGate = waitForQualityGate() // Wait for SonarQube analysis to complete and get the quality gate result
                            if (qualityGate.status != 'OK') {
                                error "Pipeline failed due to quality gate failure: ${qualityGate.status}"
                            }
                        }
                    }
                }
            }
        }
        stage('Continous Deployment') {
            stages {
                stage('CD - Build and Push to Docker Hub') {
                    steps {
                        script {
                            // Build the Docker image
                            sh "docker buildx build --platform linux/arm64,linux/amd64 -t ${IMAGE_NAME} ."
                            
                            docker.withRegistry('https://index.docker.io/v1/', 'jenkins-dockerhub') {
                                sh "docker tag ${env.IMAGE_NAME} ${env.DH_REPO}:latest"
                                sh "docker tag ${env.IMAGE_NAME} ${env.DH_REPO}:${env.BUILD_NUMBER}"
                                sh "docker tag ${env.IMAGE_NAME} ${env.DH_REPO}:${env.SEMANTIC_VERSION}"
                                sh "docker push ${env.DH_REPO}:latest"
                                sh "docker push ${env.DH_REPO}:${env.BUILD_NUMBER}"
                                sh "docker push ${env.DH_REPO}:${env.SEMANTIC_VERSION}"
                            }
                            docker.withRegistry('https://ghcr.io/v1/', 'jenkins-github') {
                                sh "docker tag ${env.IMAGE_NAME} ${env.GHCR_REPO}:latest"
                                sh "docker tag ${env.IMAGE_NAME} ${env.GHCR_REPO}:${env.BUILD_NUMBER}"
                                sh "docker tag ${env.IMAGE_NAME} ${env.GHCR_REPO}:${env.SEMANTIC_VERSION}"
                                sh "docker push ${env.GHCR_REPO}:latest"
                                sh "docker push ${env.GHCR_REPO}:${env.BUILD_NUMBER}"
                                sh "docker push ${env.GHCR_REPO}:${env.SEMANTIC_VERSION}"
                            }
                        }
                    }
                }
                stage('CD - Deploy to Kubernetes') {
                    agent {
                        docker {
                            image 'alpine/k8s:1.34'
                            reuseNode true
                        }
                    }
                    steps {
                        script {
                            withKubeConfig([credentialsId: 'k8s-cluster']) {
                            // Assuming you have kubectl configured and a deployment YAML file
                            sh "kubectl set image deployment/${env.DEPLOYMENT_NAME} ${env.CONTAINER_NAME}=${env.GHCR_REPO}:${env.BUILD_NUMBER} -n ${env.NAMESPACE}"
                            sh "kubectl rollout status deployment/${env.DEPLOYMENT_NAME} -n ${env.NAMESPACE}"
                            }
                        }
                    }
                }
            }
        }
    }
}