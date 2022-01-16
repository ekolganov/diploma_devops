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
            "KUBE_DEPLOYMENT_FE=k8s/fe-deployment-nhl_app.yaml",
            "KUBE_DEPLOYMENT_BE=k8s/be-deployment-nhl_app.yaml",
            "KUBENAMESPACEMAIN=main",
            "KUBENAMESPACEDEV=dev",
            ])
            {
                

                stage ('Build docker image') {
                    container('docker') {
                        
                        checkout([$class: 'GitSCM', branches: [[name: '*/main'], [name: '*/dev']],
                        extensions: [[$class: 'CleanBeforeCheckout', deleteUntrackedNestedRepositories: true]],
                        userRemoteConfigs: [[credentialsId: env.GIT_CRED_ID, url: env.GIT_REPO]]])                    

                        switch(env.TAG) { 
                            case ~/main-\d+\.\d+\.\d+/:
                                sh """
                                printenv &&

                                sed -i "s/__NAMESPACE__/${env.KUBENAMESPACEMAIN}/g" ${env.KUBE_DEPLOYMENT_FE} &&
                                sed -i "s/__BUILD_VERSION__/${env.TAG}/g" ${env.KUBE_DEPLOYMENT_FE} &&
                                sed -i "s/__NAMESPACE__/${env.KUBENAMESPACEMAIN}/g" ${env.KUBE_DEPLOYMENT_BE} &&
                                sed -i "s/__BUILD_VERSION__/${env.TAG}/g" ${env.KUBE_DEPLOYMENT_BE} &&

                                cd ./frontend/ &&
                                docker build -t ${DOCKERHUB_REPO_FE}:${env.TAG} . &&
                                
                                cd ../backend/ &&
                                docker build -t ${DOCKERHUB_REPO_BE}:${env.TAG} . &&
                                docker image ls
                                """
                                break
                            case ~/dev-\d+\.\d+\.\d+/:
                                sh """
                                printenv &&

                                sed -i "s/__NAMESPACE__/${env.KUBENAMESPACEDEV}/g" ${env.KUBE_DEPLOYMENT_FE} &&
                                sed -i "s/__BUILD_VERSION__/${env.TAG}/g" ${env.KUBE_DEPLOYMENT_FE} &&
                                sed -i "s/__NAMESPACE__/${env.KUBENAMESPACEDEV}/g" ${env.KUBE_DEPLOYMENT_BE} &&
                                sed -i "s/__BUILD_VERSION__/${env.TAG}/g" ${env.KUBE_DEPLOYMENT_BE} &&

                                cd ./frontend/ &&
                                docker build -t ${DOCKERHUB_REPO_FE}:${env.TAG} . &&
                                
                                cd ../backend/ &&
                                docker build -t ${DOCKERHUB_REPO_BE}:${env.TAG} . &&
                                docker image ls
                                """
                                break
                            default:
                                sh """ echo "default" && echo ${env.TAG}  && printenv  && exit 1"""
                        }
                    }
                }
            
                stage ('Push docker image') {
                    container('docker') {
                        // needed iinstall plugin docker pipelines for docker.withRegistry
                        docker.withRegistry( '', DOCKERHUB_CRED_ID ) {
                            sh """
                            docker image ls &&
                            docker push ${DOCKERHUB_REPO_FE}:${env.TAG} &&
                            docker push ${DOCKERHUB_REPO_BE}:${env.TAG}
                            """
                        }
                    }
                }

                stage ('Push yaml to Kubernetes') {
                    container('docker') {
                        // install kubectl
                        sh "apk update && apk add curl git && curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.15.1/bin/linux/amd64/kubectl && chmod u+x kubectl && mv kubectl /bin/kubectl"
                        sh """
                        kubectl apply -f ${KUBE_DEPLOYMENT_FE} &&
                        kubectl apply -f ${KUBE_DEPLOYMENT_BE}
                        """
                    }
                }
            }
        }
}
