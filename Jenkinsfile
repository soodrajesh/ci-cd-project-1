pipeline {
    agent any

    environment {
        TF_WORKSPACE = 'default' // Set the default Terraform workspace
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

                    // Determine the AWS profile based on the Terraform workspace
                    def awsProfile = terraformWorkspace == 'development' ? 'dev-user' : 'prod-user'

                    // Export AWS_PROFILE
                    sh "export AWS_PROFILE=${awsProfile}"
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    // Run Terraform plan
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
                    // Run Terraform apply
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }
    }
}
