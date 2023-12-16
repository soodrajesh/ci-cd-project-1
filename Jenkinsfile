stages {
    stage('Checkout & Environment Prep') {
        steps {
            script {
                wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
                    withCredentials([
                        [ $class: 'AmazonWebServicesCredentialsBinding',
                            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY',
                            credentialsId: 'Tikal-AWS-access',
                        ]])
                    {
                        try {
                            echo "Setting up Terraform"
                            def tfHome = tool name: 'terraform-0.12.20',
                                type: 'org.jenkinsci.plugins.terraform.TerraformInstallation'
                            env.PATH = "${tfHome}:${env.PATH}"
                            currentBuild.displayName += "[$AWS_REGION]::[$ACTION]"
                            sh("""
                                /usr/local/bin/aws configure --profile ${PROFILE} set aws_access_key_id ${AWS_ACCESS_KEY_ID}
                                /usr/local/bin/aws configure --profile ${PROFILE} set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}
                                /usr/local/bin/aws configure --profile ${PROFILE} set region ${AWS_REGION}
                                export AWS_PROFILE=${PROFILE}
                                export TF_ENV_profile=${PROFILE}
                                mkdir -p /home/jenkins/.terraform.d/plugins/linux_amd64
                            """)
                            tfCmd('version')
                        } catch (ex) {
                            echo 'Err: Incremental Build failed with Error: ' + ex.toString()
                            currentBuild.result = "UNSTABLE"
                        }
                    }
                }
            }
        }
    }        
    stage('Terraform Plan') {
        when {
            anyOf {
                environment name: 'ACTION', value: 'plan';
                environment name: 'ACTION', value: 'apply'
            }
        }
        steps {
            dir("${PROJECT_DIR}") {
                script {
                    wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
                        withCredentials([
                            [ $class: 'AmazonWebServicesCredentialsBinding',
                                accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                                secretKeyVariable: 'AWS_SECRET_ACCESS_KEY',
                                credentialsId: 'Tikal-AWS-access',
                            ]])
                        {
                            try {
                                tfCmd('plan', '-detailed-exitcode -out=tfplan')
                            } catch (ex) {
                                if (ex == 2 && "${ACTION}" == 'apply') {
                                    currentBuild.result = "UNSTABLE"
                                } else if (ex == 2 && "${ACTION}" == 'plan') {
                                    echo "Update found in plan tfplan"
                                } else {
                                    echo "Try running terraform again in debug mode"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    stage('Terraform Apply') {
        when {
            anyOf {
                environment name: 'ACTION', value: 'apply'
            }
        }
        steps {
            dir("${PROJECT_DIR}") {
                script {
                    wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
                        withCredentials([
                            [ $class: 'AmazonWebServicesCredentialsBinding',
                                accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                                secretKeyVariable: 'AWS_SECRET_ACCESS_KEY',
                                credentialsId: 'Tikal-AWS-access',
                            ]])
                        {
                            try {
                                tfCmd('apply', 'tfplan')
                            } catch (ex) {
                                currentBuild.result = "UNSTABLE"
                            }
                        }
                    }
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: "keys/key-${ENV_NAME}.*", fingerprint: true
                    archiveArtifacts artifacts: "main/show-${ENV_NAME}.txt", fingerprint: true
                }
            }
        }
    }
    stage('Terraform Destroy') {    
        when {
            anyOf {
                environment name: 'ACTION', value: 'destroy';
            }
        }
        steps {
            script {
                def IS_APPROVED = input(
                    message: "Destroy ${ENV_NAME} !?!",
                    ok: "Yes",
                    parameters: [
                        string(name: 'IS_APPROVED', defaultValue: 'No', description: 'Think again!!!')
                    ]
                )
                if (IS_APPROVED != 'Yes') {
                    currentBuild.result = "ABORTED"
                    error "User cancelled"
                }
            }
            dir("${PROJECT_DIR}") {
                script {
                    wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
                        withCredentials([
                            [ $class: 'AmazonWebServicesCredentialsBinding',
                                accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                                secretKeyVariable: 'AWS_SECRET_ACCESS_KEY',
                                credentialsId: 'Tikal-AWS-access',
                            ]])
                        {
                            try {
                                tfCmd('destroy', '-auto-approve')
                            } catch (ex) {
                                currentBuild.result = "UNSTABLE"
                            }
                        }
                    }
                }
            }
        }
    }
}
