pipeline {
    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
    } 
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        DEV_AWS_PROFILE       = 'dev-user'
        PROD_AWS_PROFILE      = 'prod-user'
    }

    agent any

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code...'
                script {
                    dir("terraform") {
                        checkout scm
                    }
                }
            }
        }

        stage('Plan') {
            steps {
                echo 'Running Terraform init and plan...'
                script {
                    sh 'cd terraform; terraform init; terraform plan -out tfplan; terraform show -no-color tfplan'
                }
            }
        }

        stage('Approval') {
            steps {
                script {
                    when {
                        not {
                            equals expected: true, actual: params.autoApprove
                        }
                    }
                    echo 'Waiting for approval...'
                    def plan = readFile 'terraform/tfplan.txt'
                    input message: "Do you want to apply the plan?",
                          parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                }
            }
        }

        stage('Apply') {
            when {
                expression { 
                    return env.BRANCH_NAME == 'development' || env.BRANCH_NAME == 'master'
                }
            }
            steps {
                script {
                    def awsProfile = env.BRANCH_NAME == 'development' ? DEV_AWS_PROFILE : PROD_AWS_PROFILE
                    echo "Applying Terraform changes to the ${env.BRANCH_NAME} branch using AWS profile: $awsProfile"
                    sh "cd terraform && AWS_PROFILE=$awsProfile terraform apply -input=false tfplan"
                }
            }
        }
    }
}
