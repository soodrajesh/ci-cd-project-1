pipeline {
    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
    } 
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID').toString()
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY').toString()
        TF_WORKING_DIR        = 'terraform'
    }

    agent any

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code...'
                script {
                    checkout scm
                }
            }
        }

        stage('Plan') {
            steps {
                echo 'Running Terraform init and plan...'
                script {
                    dir(TF_WORKING_DIR) {
                        sh 'terraform init'
                        sh 'terraform plan -out=tfplan'
                    }
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
                        dir(TF_WORKING_DIR) {
                            sh 'terraform apply -input=false tfplan'
                        }
                    } else {
                        echo 'User chose not to apply the plan. Exiting...'
                    }
                }
            }
        }
    }
}
