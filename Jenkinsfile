pipeline {
    agent any
    environment{

        // Variables
        IMAGE_NAME = 'algoan_image'        
        ARGOCD_SERVER = 'argocd.algoan.com'
        HOSTNAME = 'eu.gcr.io'      
        PROJECT_ID = 'projectAlgoanID'
    }
    
    // Alow to build Images
    stages{
        stage('Build and Push Docker Image'){
             when { branch 'master' }
             steps {
                 script {

                    docker.withRegistry('https://eu.gcr.io','gcr:projectAlgoanID') { // Login to Google Container Registry

                        def containerResistry = docker.build("${env.HOSTNAME}/${env.PROJECT_ID}/${env.IMAGE_NAME}:${env.GIT_COMMIT}"," -f Dockerfile .") // Build image
                        sh "docker push ${env.HOSTNAME}/${env.PROJECT_ID}/${env.IMAGE_NAME}:${env.GIT_COMMIT}" // Push Image
                                
                    }
                 }
             }
        }

        // Using GitOps preparing for deployment
        stage('Deploy in Stage'){
            when { branch 'dev' }
            steps {
                 // Pull the repository using SSH. Infra as code
                 // github-key: Private key create to Jenkins credential
                 git credentialsId: 'github-key', url: 'git@github.com:algoan/project.git'

                 dir("algoan"){
                     sh "cd k8s && kustomize edit set image ${env.HOSTNAME}/${env.PROJECT_ID}/${env.IMAGE_NAME}:${env.GIT_COMMIT}" // Edit image TAG
                     
                    // Using the sshagent to push the manifest
                    sshagent(['github-key']){
                       sh "git add k8s/kustomization.yaml"
                         
                       sh "git commit -m 'Publish new version'"
                       sh 'git push --set-upstream origin dev'
                       
                       
                        // Using Argocd to Continuous Delivery 
                        // Install argocd, using my public repository https://github.com/barry-ar/GitOps-Argocd
                        withCredentials([string(credentialsId: 'deploy-role', variable: 'ARGOCD_AUTH_TOKEN')]){
                            sh "argocd --grpc-web app sync ${env.PROJECT_NAME_PREPROD} --server ${env.ARGOCD_SERVER} --force"
                            sh "argocd --grpc-web app wait ${env.PROJECT_NAME_PREPROD} --server ${env.ARGOCD_SERVER} --timeout 600"
                        } 
                    }
                }
            }
        }
        
        
    }
}