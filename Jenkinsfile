pipeline {
    agent any

    environment {
        DEV_AWS_PROFILE  = 'dev-user'
        PROD_AWS_PROFILE = 'prod-user'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code...'
                checkout scm
            }
        }

        stage('Print Workspace Contents') {
            steps {
                script {
                    sh 'ls -lR ${WORKSPACE}'
                }
            }
        }

        stage('Plan') {
            steps {
                echo 'Running Terraform init and plan...'
                script {
                    sh 'cd ${WORKSPACE}/terraform; terraform init; terraform plan -out tfplan; terraform show -no-color tfplan'
                }
            }
        }

        stage('Approval') {
            steps {
                script {
                    echo 'Waiting for approval...'
                    def plan = readFile 'terraform/tfplan.txt'
                    input message: "Do you want to apply the plan?",
                          parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                }
            }
        }

        stage('Apply for Development Merge') {
            when {
                expression { 
                    return env.BRANCH_NAME == 'development' || env.CHANGE_TARGET == 'development'
                }
            }
            steps {
                script {
                    def awsProfile = DEV_AWS_PROFILE
                    echo "Applying Terraform changes for development branch merge using AWS profile: $awsProfile"
                    sh "cd ${WORKSPACE}/terraform && AWS_PROFILE=$awsProfile terraform apply -input=false tfplan"
                }
            }
        }

        stage('Apply for Main Merge') {
            when {
                expression { 
                    return env.CHANGE_TARGET == 'main'
                }
            }
            steps {
                script {
                    def awsProfile = PROD_AWS_PROFILE
                    echo "Applying Terraform changes for main branch merge using AWS profile: $awsProfile"
                    sh "cd ${WORKSPACE}/terraform && AWS_PROFILE=$awsProfile terraform apply -input=false tfplan"
                }
            }
        }
    }
}
