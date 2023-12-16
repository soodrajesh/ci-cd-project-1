pipeline {
    agent any

    environment {
        DEV_AWS_PROFILE = 'dev-user'
        PROD_AWS_PROFILE = 'prod-user'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code...'
                checkout scm
            }
        }

        stage('Set AWS Profiles') {
            steps {
                script {
                    // Determine the Terraform workspace based on the branch being built
                    def terraformWorkspace = env.BRANCH_NAME == 'main' ? 'production' : 'development'

                    // Set the appropriate AWS profile
                    def awsProfile = terraformWorkspace == 'development' ? env.DEV_AWS_PROFILE : env.PROD_AWS_PROFILE
                    sh "export AWS_PROFILE=${awsProfile}"

                    echo "Using AWS profile: ${awsProfile}"

                    // Check if AWS CLI is configured with the selected profile
                    def awsConfigured = sh(script: "aws configure list-profiles | grep -q ${awsProfile}", returnStatus: true)

                    if (awsConfigured == 0) {
                        echo "AWS profile '${awsProfile}' found in AWS CLI configuration."
                    } else {
                        echo "AWS profile '${awsProfile}' not found in AWS CLI configuration. Please configure it."
                        currentBuild.result = 'ABORTED' // Abort the build if the profile is not found
                        error "AWS profile '${awsProfile}' not found in AWS CLI configuration. Please configure it."
                    }
                }
            }
        }

        // ... (other stages remain unchanged)
    }
}
