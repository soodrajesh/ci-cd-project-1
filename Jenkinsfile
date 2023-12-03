pipeline {
    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
    } 
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID').toString()
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY').toString()
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
            when {
                not {
                    equals expected: true, actual: params.autoApprove
                }
            }

            steps {
                echo 'Waiting for approval...'
                script {
                    def plan = readFile 'terraform/tfplan.txt'
                    input message: "Do you want to apply the plan?",
                          parameters: [booleanParam(name: 'APPLY_PLAN', defaultValue: false, description: 'Proceed with applying the plan?')]
                }
            }
        }

        stage('Apply') {
            steps {
                echo 'Applying Terraform changes...'
                script {
                    if (params.APPLY_PLAN) {
                        sh 'cd terraform; terraform apply -input=false tfplan'
                    } else {
                        echo 'User chose not to apply the plan. Exiting...'
                    }
                }
            }
        }
    }
}
