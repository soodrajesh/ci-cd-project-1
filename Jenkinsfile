pipeline {
    agent any

    parameters {
        string(name: 'TerraformAction', defaultValue: 'apply', description: 'Terraform action to perform (e.g., init, plan, apply)')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage("terraform init") {
            steps {
                sh "terraform init -reconfigure"
            }
        }

        stage("plan") {
            steps {
                sh 'terraform plan'
            }
        }

        stage("Action") {
            steps {
                echo "Terraform action is --> ${params.TerraformAction}"
                sh "terraform ${params.TerraformAction} --auto-approve"
            }
        }
    }
}
