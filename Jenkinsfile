pipeline {
    agent {
         // use kube agent to start build pod in kubernetes
        kubernetes {
                yamlFile: "jenkins-agent.yaml"
            }
        }
    
    environment {
        //kubeJenkPodRunner="./k8s/jenkins-build-agent.yaml"
        //once you sign up for Docker hub, use that user_id here
        registry = "karamel32/nhl_app:0.1.1"
        //- update your credentials ID after creating credentials for connecting to Docker Hub
        registryCredential = 'dockerhub'
        // ID of creds to kube config
        configKube = "K8S"
        dockerImage = ''
        // ID of creds to github (ssh user)
        githubCred = "github"
        githubRepoName = "https://github.com/karamel32/diploma_devops.git"
        githubBuildAppPath = "frontend"
        githubBuildBranch = "main"
        
        deploymentYaml = "./k8s/fe-deployment-nhl_app.yaml"
    }
    stages {
        stage ('Build docker image') {
            steps{  
                //git branch: githubBuildBranch, credentialsId: githubCred, url: githubRepoName
                container('maven') {
                        sh "docker version"
                        //sh "docker version && cd ./$githubBuildAppPath/ && docker build -t $registry ."
                }
            }
        }
    }
}
