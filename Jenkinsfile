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

        stage('Plan') {
            steps {
                echo 'Running Terraform init and plan...'
                script {
                    sh 'terraform init; terraform plan -out tfplan; terraform show -no-color tfplan'
                }
            }
        }

        stage('Approval') {
            steps {
                script {
                    echo 'Waiting for approval...'
                    def plan = readFile 'terraform/tfplan.txt'
                    echo "Plan Content: ${plan}"  // Debug print
                    timeout(time: 10, unit: 'MINUTES') {
                        input message: "Do you want to apply the plan?",
                              parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                    }
                }
            }
        }

        stage('Apply') {
            when {
                expression { 
                    return env.BRANCH_NAME == 'development' || env.CHANGE_TARGET == 'development' || env.CHANGE_TARGET == 'main'
                }
            }
            steps {
                script {
                    def awsProfile = env.BRANCH_NAME == 'development' ? DEV_AWS_PROFILE : PROD_AWS_PROFILE
                    echo "AWS Profile: $awsProfile"  // Debug print
                    echo "Applying Terraform changes to the ${env.BRANCH_NAME} branch using AWS profile: $awsProfile"
                    sh "AWS_PROFILE=$awsProfile terraform apply -input=false terraform/tfplan"
                }
            }
        }
    }
}
