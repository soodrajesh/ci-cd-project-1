pipeline {
    agent { node { label 'tf-slave' } }

    environment {
        AWS_DEFAULT_REGION = "${params.AWS_REGION}"
        PROFILE = "${params.PROFILE}"
        ACTION = "${params.ACTION}"
        PROJECT_DIR = "terraform/main"
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '30'))
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    parameters {
        // ... (unchanged)
    }

    stages {
        stage('Checkout & Environment Prep') {
            steps {
                script {
                    // ... (unchanged)
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
                script {
                    dir("${PROJECT_DIR}") {
                        wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
                            withCredentials([
                                [ $class: 'AmazonWebServicesCredentialsBinding',
                                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY',
                                    credentialsId: 'Tikal-AWS-access',
                                ]]) {
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
                script {
                    dir("${PROJECT_DIR}") {
                        wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
                            withCredentials([
                                [ $class: 'AmazonWebServicesCredentialsBinding',
                                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY',
                                    credentialsId: 'Tikal-AWS-access',
                                ]]) {
                                try {
                                    tfCmd('apply', 'tfplan')
                                } catch (ex) {
                                    currentBuild.result = "UNSTABLE"
                                }
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
                                ]]) {
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

    post {
        always {
            emailext (
                // ... (unchanged)
            )
        }
    }
}
