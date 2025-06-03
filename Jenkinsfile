pipeline {
    agent any

    environment {
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

        stage('Terraform Init & Apply') {
            steps {
                dir('Flask-App-to-AWS-EKS/terraform') {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
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
                        echo "Fetched ECR URI: ${ecrUri}"

                        // Save to file for later use
                        writeFile file: "${env.WORKSPACE}/ecr_uri.txt", text: ecrUri
                    }
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                dir('Flask-App-to-AWS-EKS/flaskapp') {
                    script {
                        def ecrUri = readFile("${env.WORKSPACE}/ecr_uri.txt").trim()
                        echo "Using ECR URI: ${ecrUri}"
                        sh """
                            aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin ${ecrUri}
                            docker build -t ${ecrUri}:$IMAGE_TAG .
                            docker push ${ecrUri}:$IMAGE_TAG
                        """
                    }
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                dir('Flask-App-to-AWS-EKS') {
                    script {
                        def ecrUri = readFile("${env.WORKSPACE}/ecr_uri.txt").trim()
                        sh """
                            aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION
                            cp deployment-template.yaml deployment.yaml
                            sed -i "s|<ECR_IMAGE_PLACEHOLDER>|${ecrUri}:$IMAGE_TAG|g" deployment.yaml
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
