pipeline {
    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
    } 
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
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
                    sh 'cd terraform; terraform init; terraform plan'
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
                    input message: 'Do you want to apply the plan?',
                          ok: 'Proceed',
                          parameters: [booleanParam(defaultValue: false, description: 'Apply the plan?', name: 'APPLY_PLAN')]
                }
            }
        }

        stage('Apply') {
            steps {
                echo 'Applying Terraform changes...'
                script {
                    if (params.APPLY_PLAN) {
                        sh 'cd terraform; terraform apply -input=false'
                    } else {
                        echo 'User chose not to apply the plan. Exiting...'
                    }
                }
            }
        }
    }
}
