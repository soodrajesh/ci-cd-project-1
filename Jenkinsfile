pipeline {
    agent any

    environment {
        DEV_AWS_PROFILE  = 'dev-user'
        PROD_AWS_PROFILE = 'prod-user'
        AWS_PROFILE = '' // Initialize AWS_PROFILE to an empty string
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
                        // After creating the workspace, select it again
                        sh "terraform workspace select ${terraformWorkspace}"
                    }

                    // Set the Terraform workspace
                    sh "terraform workspace select ${terraformWorkspace}"

                    // Determine the AWS profile based on the branch being merged
                    AWS_PROFILE = env.BRANCH_NAME == 'main' ? PROD_AWS_PROFILE : DEV_AWS_PROFILE
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
                    // Run Terraform apply with the dynamically determined AWS profile
                    sh "AWS_PROFILE=${AWS_PROFILE} terraform apply -auto-approve tfplan"
                }
            }
        }
    }
}
