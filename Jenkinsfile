pipeline {
    agent any

    environment {
        DEV_AWS_ACCESS_KEY_ID = credentials('ac1-dev-aws-accesskey-id')
        DEV_AWS_SECRET_ACCESS_KEY = credentials('ac1-dev-aws-secretaccesskey-id')
        PROD_AWS_ACCESS_KEY_ID = credentials('ac1-prod-aws-accesskey-id')
        PROD_AWS_SECRET_ACCESS_KEY = credentials('ac2-prod-aws-secretaccesskey-id')
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

        stage('Set AWS Profiles') {
            steps {
                script {
                    // Determine the Terraform workspace based on the branch being built
                    def terraformWorkspace = env.BRANCH_NAME == 'main' ? 'production' : 'development'

                    // Set the appropriate AWS credentials
                    def awsAccessKeyId = terraformWorkspace == 'development' ? env.DEV_AWS_ACCESS_KEY_ID : env.PROD_AWS_ACCESS_KEY_ID
                    def awsSecretAccessKey = terraformWorkspace == 'development' ? env.DEV_AWS_SECRET_ACCESS_KEY : env.PROD_AWS_SECRET_ACCESS_KEY
                    def awsRegion = terraformWorkspace == 'development' ? env.DEV_AWS_REGION : env.PROD_AWS_REGION

                    // Set environment variables for AWS CLI
                    withCredentials([
                        [$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY', credentialsId: awsAccessKeyId]
                    ]) {
                        sh "export AWS_REGION=${awsRegion}"
                        sh "export AWS_PROFILE=${awsAccessKeyId}"  // You can use credentials ID as the profile name
                    }

                    echo "Using AWS profile: ${awsAccessKeyId} in region: ${awsRegion}"
                }
            }
        }

        stage('Terraform Init') {
                    steps {
                        script {
                            sh 'terraform init'
                        }
                    }
                }

                stage('Terraform Select Workspace') {
                    steps {
                        script {
                            // Determine the Terraform workspace based on the branch being built
                            def terraformWorkspace = env.BRANCH_NAME == 'main' ? env.PROD_TF_WORKSPACE : env.DEV_TF_WORKSPACE

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
                            sh 'terraform apply -auto-approve tfplan'
                        }
                    }
                }
            }
        }
    