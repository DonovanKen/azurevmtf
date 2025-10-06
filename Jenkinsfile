pipeline {
  agent any
  options { timestamps() }

  parameters {
    string(name: 'TF_DIR', defaultValue: '.', description: 'Chemin vers le code Terraform')
    string(name: 'DO_APPLY', defaultValue: 'true', description: 'true/false pour exécuter terraform apply')
  }

  environment {
    TF_IN_AUTOMATION = 'true'
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Terraform Init & Plan') {
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

              terraform version
              terraform init -input=false
              terraform plan -out=tfplan
            '''
          }
        }
      }
    }

    // stage('Terraform Apply (optionnel)') {
    //   when { expression { params.DO_APPLY?.trim()?.toLowerCase() in ['true','yes','y','1'] } }
    //   steps {
    //     dir(params.TF_DIR) {
    //       withCredentials([
    //         string(credentialsId: 'ARM_SUBSCRIPTION_ID', variable: 'SUB'),
    //         string(credentialsId: 'ARM_TENANT_ID',       variable: 'TEN'),
    //         string(credentialsId: 'ARM_CLIENT_ID',       variable: 'CID'),
    //         string(credentialsId: 'ARM_CLIENT_SECRET',   variable: 'CSEC'),
    //         string(credentialsId: 'SSH_PUBLIC_KEY',      variable: 'PUBKEY')
    //       ]) {
    //         sh '''
    //           set -e
    //           export TF_VAR_subscription_id="$SUB"
    //           export TF_VAR_tenant_id="$TEN"
    //           export TF_VAR_client_id="$CID"
    //           export TF_VAR_client_secret="$CSEC"
    //           export TF_VAR_ssh_public_key="$PUBKEY"

    //           terraform apply -auto-approve tfplan
    //         '''
    //       }
    //     }
    //   }
    // }
  }

  post {
    always {
      archiveArtifacts artifacts: 'tfplan', onlyIfSuccessful: true
      cleanWs()
    }
  }
}
