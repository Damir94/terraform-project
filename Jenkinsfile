pipeline {
    agent any

    environment {
        // Reference Jenkins credentials
        AWS_ACCESS_KEY_ID = credentials("aws_access_key_id")
        AWS_SECRET_ACCESS_KEY = credentials("aws_secret_access_key")
    }

    stages {
        stage('Checkout') {
            steps {
                // Correct syntax for the 'git' step
                git(branch: "main", credentialsId: "b167ad00-4d65-44b7-8e59-f018ad1f05db", url: "https://github.com/Damir94/terraform-project.git")
            }
        }
        
        stage('Terraform Init') {
            steps {
                script {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Destroy') {
            steps {
                script {
                    // Command to destroy the infrastructure
                    sh 'terraform workspace select Terraform-Standalone'
                    sh 'terraform destroy -auto-approve'
                }
            }
        }
    }
    
    post {
        always {
            // Clean up workspace or send notifications
            cleanWs()
        }
    }
}
