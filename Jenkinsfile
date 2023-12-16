pipeline {
    agent any

    environment {
        DEV_AWS_ACCESS_KEY_ID = credentials('aws-dev-user')
        PROD_AWS_ACCESS_KEY_ID = credentials('aws-prod-user')
        DEV_AWS_REGION = 'us-west-2'
        PROD_AWS_REGION = 'us-west-2'
        DEV_TF_WORKSPACE = 'development'
        PROD_TF_WORKSPACE = 'production'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code...'
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                script {
                    sh 'terraform init -backend-config=../config.tfbackendt'
                }
            }
        }

        stage('Terraform Select Workspace') {
            steps {
                script {
                    def terraformWorkspace
                    def awsCredentialsId

                    if (env.BRANCH_NAME == 'main') {
                        terraformWorkspace = PROD_TF_WORKSPACE
                        awsCredentialsId = 'aws-prod-user'
                    } else {
                        terraformWorkspace = DEV_TF_WORKSPACE
                        awsCredentialsId = 'aws-dev-user'
                    }

                    def awsAccessKeyId

                    // Retrieve AWS credentials from Jenkins
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: awsCredentialsId, accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                        awsAccessKeyId = env.AWS_ACCESS_KEY_ID
                    }

                    echo "Using AWS credentials:"
                    //echo "  Access Key ID: ${awsAccessKeyId}"
                    echo "Credentials ID: ${awsCredentialsId}"

                    // Check if the Terraform workspace exists
                    def workspaceExists = sh(script: "terraform workspace list | grep -q ${terraformWorkspace}", returnStatus: true)

                    if (workspaceExists == 0) {
                        echo "Terraform workspace '${terraformWorkspace}' exists."
                    } else {
                        echo "Terraform workspace '${terraformWorkspace}' doesn't exist. Creating..."
                        sh "terraform workspace new ${terraformWorkspace}"
                    }

                    // Set the Terraform workspace
                    sh "terraform workspace select ${terraformWorkspace}"
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    // Additional steps if needed
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Manual Approval') {
            steps {
                script {
                    echo 'Waiting for approval...'
                    input message: 'Do you want to apply the Terraform plan?',
                          ok: 'Proceed'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    // Ensure awsCredentialsId is defined in this scope
                    def awsCredentialsId

                    if (env.BRANCH_NAME == 'main') {
                        awsCredentialsId = 'aws-prod-user'
                    } else {
                        awsCredentialsId = 'aws-dev-user'
                    }

                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: awsCredentialsId, accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                        sh 'terraform apply -auto-approve tfplan'
                    }
                }
            }
        }
    }
}
