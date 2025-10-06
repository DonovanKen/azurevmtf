pipeline {
  agent any
  options { timestamps() }

  parameters {
    string(name: 'TF_DIR', defaultValue: '.', description: 'Path to Terraform code')
    // apply ON by default so VMs are created
    string(name: 'DO_APPLY', defaultValue: 'true', description: 'true/false to run terraform apply')
  }

  environment { TF_IN_AUTOMATION = 'true' }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Bootstrap Terraform (if needed)') {
      steps {
        dir(params.TF_DIR) {
          sh '''
            set -e
            if ! command -v terraform >/dev/null 2>&1; then
              echo "Terraform not found, downloading locally..."
              TF_VERSION=1.9.5
              mkdir -p .bin
              curl -sLo terraform.zip https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip
              unzip -o terraform.zip >/dev/null
              mv -f terraform .bin/terraform
              rm -f terraform.zip
            fi
            export PATH="$PWD/.bin:$PATH"
            terraform version
          '''
        }
      }
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
              export PATH="$PWD/.bin:$PATH"

              # Inject Azure SP + SSH pubkey to Terraform variables
              export TF_VAR_subscription_id="$SUB"
              export TF_VAR_tenant_id="$TEN"
              export TF_VAR_client_id="$CID"
              export TF_VAR_client_secret="$CSEC"
              export TF_VAR_ssh_public_key="$PUBKEY"

              terraform init -input=false
              terraform plan -out=tfplan
            '''
          }
        }
      }
    }

    // stage('Terraform Apply (create Azure VMs)') {
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
    //           export PATH="$PWD/.bin:$PATH"
    //           export TF_VAR_subscription_id="$SUB"
    //           export TF_VAR_tenant_id="$TEN"
    //           export TF_VAR_client_id="$CID"
    //           export TF_VAR_client_secret="$CSEC"
    //           export TF_VAR_ssh_public_key="$PUBKEY"

    //           ([ -f tfplan ] && terraform apply -auto-approve tfplan) || terraform apply -auto-approve
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
