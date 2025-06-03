pipeline {
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

                        // Check and import existing ECR repo
                        def ecrRepoExists = sh (
                            script: "aws ecr describe-repositories --repository-names my-flask-repo --region $REGION > /dev/null 2>&1 && echo yes || echo no",
                            returnStdout: true
                        ).trim()

                        if (ecrRepoExists == 'yes') {
                            echo "ECR repo exists. Importing into Terraform state."
                            sh 'terraform import module.ecr.aws_ecr_repository.repo my-flask-repo || echo "Already imported or import failed."'
                        } else {
                            echo "ECR repo does not exist. Will be created by Terraform."
                        }

                        // Check and import existing IAM role
                        def iamRoleExists = sh (
                            script: "aws iam get-role --role-name eks-cluster-role > /dev/null 2>&1 && echo yes || echo no",
                            returnStdout: true
                        ).trim()

                        if (iamRoleExists == 'yes') {
                            echo "IAM role exists. Importing."
                            sh 'terraform import module.eks.aws_iam_role.eks_role eks-cluster-role || echo "Already imported or import failed."'
                        } else {
                            echo "IAM role does not exist. Will be created."
                        }

                        // Check and import existing EKS cluster
                        def eksExists = sh (
                            script: "aws eks describe-cluster --name $CLUSTER_NAME --region $REGION > /dev/null 2>&1 && echo yes || echo no",
                            returnStdout: true
                        ).trim()

                        if (eksExists == 'yes') {
                            echo "EKS cluster exists. Importing into Terraform."
                            sh """
                                terraform import module.eks.aws_eks_cluster.this[0] $CLUSTER_NAME || echo "Already imported or import failed."
                                terraform import module.eks.aws_eks_node_group.default $CLUSTER_NAME:$CLUSTER_NAME-nodegroup || echo "Already imported or import failed."
                            """
                        } else {
                            echo "EKS cluster does not exist. Will be created."
                        }
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
                            script: "terraform output -raw repository_url",
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
