pipeline {
  agent any

  parameters {
    string(name: 'TF_DIR', defaultValue: '.', description: 'Path to Terraform code')
  }

  environment { TF_IN_AUTOMATION = 'true' }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Terraform Init') {
      steps {
        dir(params.TF_DIR) {
          withCredentials([
            string(credentialsId: 'ARM_SUBSCRIPTION_ID', variable: 'SUB'),
            string(credentialsId: 'ARM_TENANT_ID',       variable: 'TEN'),
            string(credentialsId: 'ARM_CLIENT_ID',       variable: 'CID'),
            string(credentialsId: 'ARM_CLIENT_SECRET',   variable: 'CSEC'),
            string(credentialsId: 'SSH_PUBLIC_KEY',      variable: 'PUBKEY')
          ]) {
            sh '''
              set -e
              export TF_VAR_subscription_id="$SUB"
              export TF_VAR_tenant_id="$TEN"
              export TF_VAR_client_id="$CID"
              export TF_VAR_client_secret="$CSEC"
              export TF_VAR_ssh_public_key="$PUBKEY"

              terraform init -input=false
            '''
          }
        }
      }
    }

    stage('Terraform Plan') {
      steps {
        dir(params.TF_DIR) {
          sh 'terraform plan -out=tfplan'
        }
      }
    }

    stage('Terraform Apply') {
      steps {
        dir(params.TF_DIR) {
          sh '([ -f tfplan ] && terraform apply -auto-approve tfplan) || terraform apply -auto-approve'
        }
      }
    }
  }
}
