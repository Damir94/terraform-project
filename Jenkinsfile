pipeline {
    agent any

    environment {
        // Reference Jenkins credentials
        AWS_ACCESS_KEY_ID = credentials('aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
    }

    stages {
        stage('Checkout') {
            steps {
                // Correct syntax for the 'git' step
                git(branch: 'main', credentialsId: 'b167ad00-4d65-44b7-8e59-f018ad1f05db', url: 'https://github.com/Damir94/terraform-project.git')
            }
        }
        
        stage('Init') {
            steps {
                sh 'terraform init'
            }
        }
        
        stage('Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }
        
        stage('Apply') {
            steps {
                sh 'terraform apply -input=false tfplan'
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
