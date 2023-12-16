pipeline {
    agent any

    environment {
        DEV_AWS_PROFILE = 'dev-user'
        PROD_AWS_PROFILE = 'prod-user'
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

                    // Set the appropriate AWS profile
                    def awsProfile = terraformWorkspace == 'development' ? env.DEV_AWS_PROFILE : env.PROD_AWS_PROFILE

                    // Use Jenkins credentials to retrieve AWS credentials
                    withCredentials([
                        [ $class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: "${awsProfile}-AccessKey"],
                        [ $class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_SECRET_ACCESS_KEY', credentialsId: "${awsProfile}-SecretKey"]
                    ]) {
                        // Export the AWS profile
                        sh "export AWS_PROFILE=${awsProfile}"

                        echo "Using AWS profile: ${awsProfile}"

                        // Check if AWS CLI is configured with the selected profile
                        def awsConfigured = sh(script: "aws configure list-profiles | grep -q ${awsProfile}", returnStatus: true)

                        if (awsConfigured == 0) {
                            echo "AWS profile '${awsProfile}' found in AWS CLI configuration."
                        } else {
                            echo "AWS profile '${awsProfile}' not found in AWS CLI configuration. Please configure it."
                            currentBuild.result = 'ABORTED' // Abort the build if the profile is not found
                            error "AWS profile '${awsProfile}' not found in AWS CLI configuration. Please configure it."
                        }
                    }
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
                    def terraformWorkspace = env.BRANCH_NAME == 'main' ? 'production' : 'development'

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
