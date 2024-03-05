pipeline {

    agent any

    environment{
	
         
		 GIT_SSH_COMMAND = "ssh -o StrictHostKeyChecking=no"
        // AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')

        // AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')

        // EKS_CLUSTER = 'test-cluster-1'

       

    }

    stages {

        stage('Checkout') {

            steps {

                git branch: 'main', url: 'https://github.com/Nandhini-16/Testing-cluster-eks.git'
            }

        }
		 stage('Configure kubectl Agent') {
            steps {
                script {
                    // Install Docker on the Jenkins agent if not already installed
                    // sh 'which docker || (curl -fsSL https://get.docker.com | sh)'
                    // Install kubectl on the Jenkins agent if not already installed
                    sh 'curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl'
                    sh 'chmod +x kubectl'
                    //sh 'mv kubectl /usr/local/bin/'
                }
            }
        }
        stage('Build') {
            steps {
                script {
                    def buildNumber = env.BUILD_NUMBER
                    sh "docker build -t containerregprojectx.azurecr.io/cloud-test:${buildNumber} ."
                }
            }
        }
        stage('Login and push image to ACR') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'containerregprojectx', passwordVariable: 'password', usernameVariable: 'username')]) {
                    script {
                        def buildNumber = env.BUILD_NUMBER
                        sh "docker login -u ${username} -p ${password} containerregprojectx.azurecr.io" 
                        sh "docker push containerregprojectx.azurecr.io/cloud-test:${buildNumber}"
                    }
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                container('kubectl') {
                    withCredentials([kubeconfigFile(credentialsId: 'Nandhini-cluster', variable: 'KUBECONFIG')]) {
                        sh '''
                            export KUBECONFIG=$KUBECONFIG
                            kubectl apply -f node-deployment.yaml
                        '''
                    }
                }
            }
        }
    }
}
