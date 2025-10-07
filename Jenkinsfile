pipeline {
    agent any

    parameters {
        string(name: 'TF_DIR', defaultValue: '.', description: 'Path to Terraform code')
        string(name: 'LOCATION', defaultValue: 'North Europe', description: 'Azure region')
        string(name: 'RG_NAME', defaultValue: 'rg-k8s-lab', description: 'Resource Group')
        string(name: 'VN_NAME', defaultValue: 'vnet-k8s', description: 'VNet name')
        string(name: 'VN_CIDR', defaultValue: '10.0.0.0/16', description: 'VNet CIDR')
        string(name: 'SUBNET_NAME', defaultValue: 'snet-k8s', description: 'Subnet name')
        string(name: 'SUBNET_CIDR', defaultValue: '10.0.1.0/24', description: 'Subnet CIDR')
        string(name: 'NSG_RULES_JSON', defaultValue: '[{"name":"ssh","priority":100,"direction":"Inbound","access":"Allow","protocol":"Tcp","source_port_range":"*","destination_port_range":"22","source_address_prefix":"*","destination_address_prefix":"*"}]')
    }

    environment {
        TF_IN_AUTOMATION = 'true'
        TF_INPUT = '0'
    }

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Terraform Init') {
            steps {
                dir(params.TF_DIR) {
                    withEnv([
                        "TF_VAR_location=${params.LOCATION}",
                        "TF_VAR_resource_group_name=${params.RG_NAME}",
                        "TF_VAR_vn_name=${params.VN_NAME}",
                        "TF_VAR_vn_address=[\"${params.VN_CIDR}\"]",
                        "TF_VAR_subnet_name=${params.SUBNET_NAME}",
                        "TF_VAR_subnet_address=${params.SUBNET_CIDR}",
                        "TF_VAR_nsg_rules=${params.NSG_RULES_JSON}"
                    ]) {
                        withCredentials([
                            string(credentialsId: 'ARM_SUBSCRIPTION_ID', variable: 'SUB'),
                            string(credentialsId: 'ARM_TENANT_ID', variable: 'TEN'),
                            string(credentialsId: 'ARM_CLIENT_ID', variable: 'CID'),
                            string(credentialsId: 'ARM_CLIENT_SECRET', variable: 'CSEC'),
                            string(credentialsId: 'SSH_PUBLIC_KEY', variable: 'PUBKEY')
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
        }

        stage('Terraform Plan') {
            steps {
                dir(params.TF_DIR) {
                    withEnv([
                        "TF_VAR_location=${params.LOCATION}",
                        "TF_VAR_resource_group_name=${params.RG_NAME}",
                        "TF_VAR_vn_name=${params.VN_NAME}",
                        "TF_VAR_vn_address=[\"${params.VN_CIDR}\"]",
                        "TF_VAR_subnet_name=${params.SUBNET_NAME}",
                        "TF_VAR_subnet_address=${params.SUBNET_CIDR}",
                        "TF_VAR_nsg_rules=${params.NSG_RULES_JSON}"
                    ]) {
                        withCredentials([
                            string(credentialsId: 'ARM_SUBSCRIPTION_ID', variable: 'SUB'),
                            string(credentialsId: 'ARM_TENANT_ID', variable: 'TEN'),
                            string(credentialsId: 'ARM_CLIENT_ID', variable: 'CID'),
                            string(credentialsId: 'ARM_CLIENT_SECRET', variable: 'CSEC'),
                            string(credentialsId: 'SSH_PUBLIC_KEY', variable: 'PUBKEY')
                        ]) {
                            sh '''
                                set -e
                                export TF_VAR_subscription_id="$SUB"
                                export TF_VAR_tenant_id="$TEN"
                                export TF_VAR_client_id="$CID"
                                export TF_VAR_client_secret="$CSEC"
                                export TF_VAR_ssh_public_key="$PUBKEY"
                                terraform plan -input=false -out=tfplan
                            '''
                        }
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir(params.TF_DIR) {
                    withEnv([
                        "TF_VAR_location=${params.LOCATION}",
                        "TF_VAR_resource_group_name=${params.RG_NAME}",
                        "TF_VAR_vn_name=${params.VN_NAME}",
                        "TF_VAR_vn_address=[\"${params.VN_CIDR}\"]",
                        "TF_VAR_subnet_name=${params.SUBNET_NAME}",
                        "TF_VAR_subnet_address=${params.SUBNET_CIDR}",
                        "TF_VAR_nsg_rules=${params.NSG_RULES_JSON}"
                    ]) {
                        withCredentials([
                            string(credentialsId: 'ARM_SUBSCRIPTION_ID', variable: 'SUB'),
                            string(credentialsId: 'ARM_TENANT_ID', variable: 'TEN'),
                            string(credentialsId: 'ARM_CLIENT_ID', variable: 'CID'),
                            string(credentialsId: 'ARM_CLIENT_SECRET', variable: 'CSEC'),
                            string(credentialsId: 'SSH_PUBLIC_KEY', variable: 'PUBKEY')
                        ]) {
                            sh '''
                                set -e
                                export TF_VAR_subscription_id="$SUB"
                                export TF_VAR_tenant_id="$TEN"
                                export TF_VAR_client_id="$CID"
                                export TF_VAR_client_secret="$CSEC"
                                export TF_VAR_ssh_public_key="$PUBKEY"
                                ([ -f tfplan ] && terraform apply -input=false -auto-approve tfplan) || terraform apply -input=false -auto-approve
                            '''
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'tfplan', onlyIfSuccessful: true
        }
    }
}
