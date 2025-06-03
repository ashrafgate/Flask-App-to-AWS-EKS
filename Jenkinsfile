rpipeline {
    agent any

    environment {
        ECR_URI      = ''
        IMAGE_TAG    = 'latest'
        CLUSTER_NAME = 'my-flask-cluster'
        REGION       = 'ap-south-1'
    }

    stages {
        stage('Clean Workspace') {
            steps {
                deleteDir()
            }
        }

        stage('Git Clone') {
            steps {
                sh 'git clone --branch main https://github.com/ashrafgate/Flask-App-to-AWS-EKS.git'
            }
        }

        stage('Terraform Init & Import Existing Resources') {
            steps {
                dir('Flask-App-to-AWS-EKS/terraform') {
                    script {
                        sh 'terraform init'

                        }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('Flask-App-to-AWS-EKS/terraform') {
                    script {
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }

        stage('Get ECR URI') {
			steps {
				dir('Flask-App-to-AWS-EKS/terraform') {
					script {
						def ecrUri = sh(
							script: "terraform output -raw ecr_repository_url",
							returnStdout: true
						).trim()
						env.ECR_URI = ecrUri
						echo "ECR URI: ${env.ECR_URI}"
					}
				}
			}
		}


        stage('Docker Build & Push') {
            steps {
                dir('Flask-App-to-AWS-EKS/flaskapp') {
                    script {
                        sh """
                            aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin ${env.ECR_URI}
                            docker build -t ${env.ECR_URI}:$IMAGE_TAG .
                            docker push ${env.ECR_URI}:$IMAGE_TAG
                        """
                    }
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                dir('Flask-App-to-AWS-EKS') {
                    script {
                        sh """
                            aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION
                            cp deployment-template.yaml deployment.yaml
                            sed -i "s|<ECR_IMAGE_PLACEHOLDER>|${env.ECR_URI}:$IMAGE_TAG|g" deployment.yaml
                            kubectl apply -f deployment.yaml
                            kubectl apply -f service.yaml
                        """
                    }
                }
            }
        }
    }

    post {
        failure {
            echo "Pipeline failed! Check the logs."
        }
        success {
            echo "Pipeline completed successfully."
        }
    }
}
