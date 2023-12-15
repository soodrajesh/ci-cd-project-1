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
                    sh 'terraform init'
                    sh 'terraform plan -no-color'
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
                    echo "Applying Terraform changes to the ${env.BRANCH_NAME} branch using AWS profile: $awsProfile"
                    sh "terraform apply -input=false -auto-approve -var 'aws_profile=$awsProfile'"
                }
            }
        }
    }
}
