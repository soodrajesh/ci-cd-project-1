pipeline {
    agent any

    environment {
        TF_WORKSPACE   = 'dev' // Set the default Terraform workspace
        DEV_AWS_PROFILE  = 'dev-user' // Set the default AWS CLI profile for development
        PROD_AWS_PROFILE = 'prod-user' // Set the default AWS CLI profile for production
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
                    // Set the AWS profile based on the branch being built
                    def awsProfile = env.BRANCH_NAME == 'main' ? PROD_AWS_PROFILE : DEV_AWS_PROFILE
                    
                    // Explicitly set the AWS_PROFILE environment variable
                    sh "AWS_PROFILE=${awsProfile} terraform apply -auto-approve tfplan"
                }
            }
        }
    }
}
