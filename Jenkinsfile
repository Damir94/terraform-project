pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials("aws_access_key_id")
        AWS_SECRET_ACCESS_KEY = credentials("aws_secret_access_key")
    }

    stages {
        stage('Checkout') {
            steps {
                git(branch: "main", credentialsId: "b167ad00-4d65-44b7-8e59-f018ad1f05db", url: "https://github.com/Damir94/terraform-project.git")
            }
        }
        
        stage('Init') {
            steps {
                sh 'terraform init'
            }
        }
        
        stage('Plan') {
            steps {
                sh 'terraform plan -auto-approve'
            }
        }
        
        stage('Apply') {
            steps {
                sh 'terraform apply -auto-approve'
            }
        }

        stage('Wait Before Destroy') { 
            steps { 
                script {
                    echo "Waiting for 5 minutes before destroying the infrastructure..."
                    sleep 300  // Sleep for 300 seconds (5 minutes)
                }
            } 
        }
    
        stage('Terraform Destroy') { 
            steps {
                sh 'terraform destroy -auto-approve'
            }  
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}

