podTemplate(yaml: '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: docker
    image: docker:19.03.1-dind
    securityContext:
      privileged: true
    env:
      - name: DOCKER_TLS_CERTDIR
        value: ""
''')
{
    node(POD_LABEL) {
        withEnv([
            "DOCKERHUB_REPO_FE=karamel32/nhl_app",
            "DOCKERHUB_REPO_BE=karamel32/nhl_app_be",
            "DOCKERHUB_CRED_ID=dockerhub",
            "KUBE_CRED_ID=K8S",
            "GIT_CRED_ID=github",
            "GIT_REPO=https://github.com/karamel32/diploma_devops",
            "KUBE_DEPLOYMENT_FE=./k8s/ffe-deployment-nhl_app.yaml",
            "KUBE_DEPLOYMENT_BE=./k8s/be-deployment-nhl_app.yaml"
            ])
            {
            

            stage ('Build docker image') {
                container('docker') {
                    
                    checkout([$class: 'GitSCM', branches: [[name: '*/main'], [name: '*/dev']],
                    extensions: [[$class: 'CleanBeforeCheckout', deleteUntrackedNestedRepositories: true]],
                    userRemoteConfigs: [[credentialsId: env.GIT_CRED_ID, url: env.GIT_REPO]]])                    
                    
                    
                    switch(env.BRANCH) { 
                        case "origin/main":
                            sh """ echo ${env.BRANCH} && printenv && ls -la """
                            break
                        case "origin/dev":
                            sh """ echo ${env.BRANCH}  && printenv """
                            break                            
                        default:
                            sh """ error branches """
                            exit 1
                    }
                    /*if (env.BRANCH_NAME == 'master') {
                    
                        //sh "docker version"
                        sh """printenv && docker version && ls -la && echo ${env.GIT_REPO} && echo ${GIT_REPO} && echo ${KUBE_DEPLOYMENT_BE}"""
                        sh """ ${env.BRANCH_NAME} """
                        
                    } else {
                        sh """printenv && ls -la"""
                        sh """ ${env.BRANCH_NAME} """
                    }*/

                    //sh "docker version && cd ./$githubBuildAppPath/ && docker build -t $registry ."
                }
            }
            
            stage ('Push docker image') {
                container('docker') {

                    //sh "docker version && cd ./$githubBuildAppPath/ && docker build -t $registry ."
                }
            }
        }
    }
}
