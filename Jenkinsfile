pipeline {
    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
    } 
    environment {
        AWS_PROFILE = 'rsood' // Set your AWS named profile here
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
                    sh 'cd terraform; terraform init; terraform plan -out tfplan; terraform show -no-color tfplan > tfplan.txt'
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
                          parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                }
            }
        }

        stage('Apply') {
            steps {
                echo 'Applying Terraform changes...'
                script {
                    sh 'cd terraform; AWS_PROFILE=$AWS_PROFILE terraform apply -input=false tfplan'
                }
            }
        }
    }
}
