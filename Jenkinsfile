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
                    return env.BRANCH_NAME == 'development' || env.CHANGE_TARGET == 'development' || (env.BRANCH_NAME == 'main' && env.CHANGE_TARGET == 'development')
                }
            }
            steps {
                script {
                    echo "Debug: Entering Apply stage"

                    // Determine the AWS profile based on the branch being merged
                    def awsProfile = env.BRANCH_NAME == 'development' ? DEV_AWS_PROFILE : PROD_AWS_PROFILE
                    echo "AWS Profile: $awsProfile"  // Debug print
                    echo "Applying Terraform changes to the ${env.BRANCH_NAME} branch using AWS profile: $awsProfile"
                    
                    // Run Terraform apply with debug output and use the workspace
                    sh "terraform apply -input=false -auto-approve -var 'aws_profile=$awsProfile'"

                    echo "Debug: Terraform apply completed"
                }
            }
        }
    }
}
