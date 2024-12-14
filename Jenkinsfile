pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = "586794476819"
        REGION = "ap-south-1"
        ECR_URL = "${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
        IMAGE_TAG = "mfusion-ms-v.1.${env.BUILD_NUMBER}"
        IMAGE_NAME = "sayalisawant12/mfusion-ms:${IMAGE_TAG}"
        ECR_IMAGE_NAME = "${ECR_URL}/mfusion-ms:${IMAGE_TAG}"
        KUBECONFIG_ID = 'kubeconfig-fusion-k8s-cluster'
    }

    tools {
        maven 'Apache Maven 3.9.4'
    }

    stages {
        stage('Build and Test') {
            when { branch 'dev' }
            steps {
                echo 'Running Build and Test'
                sh 'mvn clean test'
            }
        }

        stage('Docker Image') {
            steps {
                echo "Building Docker Image: ${env.IMAGE_NAME}"
                sh """
                    docker build -t ${env.IMAGE_NAME} .
                    docker tag ${env.IMAGE_NAME} ${env.ECR_IMAGE_NAME}
                """
            }
        }

        stage('Push to DockerHub and ECR') {
            parallel {
                stage('DockerHub') {
                    steps {
                        withCredentials([usernamePassword(credentialsId: 'DOCKER_HUB_CRED', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                            sh """
                                docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}
                                docker push ${env.IMAGE_NAME}
                            """
                        }
                    }
                }
                stage('Amazon ECR') {
                    steps {
                        withDockerRegistry([credentialsId: 'ecr:ap-south-1:ecr-credentials', url: "https://${ECR_URL}"]) {
                            sh "docker push ${env.ECR_IMAGE_NAME}"
                        }
                    }
                }
            }
        }

        stage('Deploy to K8s') {
            when { branch 'dev' }
            steps {
                script {
                    deployToK8s('dev', 'kubernetes/dev/')
                }
            }
        }
    }

    post {
        success { echo "Pipeline executed successfully" }
        failure { echo "Pipeline failed. Check logs." }
    }
}

def deployToK8s(envName, yamlDir) {
    def yamlFiles = ['00-ingress.yaml', '02-service.yaml', '03-service-account.yaml', '05-deployment.yaml', '06-configmap.yaml', '09.hpa.yaml']
    yamlFiles.each { yamlFile ->
        sh """
            kubectl apply -f ${yamlDir}${yamlFile} -n ${envName}
        """
    }
}
