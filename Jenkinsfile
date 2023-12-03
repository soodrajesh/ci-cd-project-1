pipeline {
    agent any

    environment {
        TF_WORKING_DIR = 'terraform'
        TF_PLAN_FILE = "${TF_WORKING_DIR}/tfplan"
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID').toString()
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY').toString()
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code...'
                checkout scm
            }
        }

        stage('Terraform Init and Plan') {
            when {
                expression { 
                    return env.BRANCH_NAME == 'develop' || env.BRANCH_NAME ==~ /^jira-\d+$/ 
                }
            }
            steps {
                echo 'Running Terraform init and plan...'
                dir(TF_WORKING_DIR) {
                    script {
                        sh 'terraform init'
                        sh 'terraform plan -out tfplan'
                        sh 'terraform show -no-color tfplan'
                    }
                }
            }
        }

        
        stage('Manual Approval for Merge') {
            when {
                expression { 
                    return env.BRANCH_NAME == 'develop' || env.BRANCH_NAME ==~ /^jira-\d+$/ 
                }
            }
            steps {
                echo 'Waiting for manual approval...'
                input message: "Do you want to merge the code?",
                      parameters: [booleanParam(name: 'MERGE_APPROVAL', defaultValue: false, description: 'Proceed with merging the code?')]
            }
        }

        stage('Terraform Apply') {
            when {
                expression { 
                    return env.BRANCH_NAME == 'develop' || env.BRANCH_NAME ==~ /^jira-\d+$/ 
                }
            }
            steps {
                echo 'Applying Terraform changes...'
                dir(TF_WORKING_DIR) {
                    script {
                        if (params.MERGE_APPROVAL) {
                            sh 'terraform apply -auto-approve tfplan'
                        } else {
                            echo 'User chose not to apply the plan. Exiting...'
                        }
                    }
                }
            }
        }
    }
}
