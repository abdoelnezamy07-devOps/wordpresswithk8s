pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: jenkins-build-agent
spec:
  containers:
  - name: helm-kubectl
    image: alpine/k8s:1.28.2
    command:
    - cat
    tty: true
  - name: trivy
    image: ghcr.io/aquasecurity/trivy:latest
    command:
    - cat
    tty: true
'''
        }
    }

    environment {
        HELM_RELEASE_NAME = 'wordpress'
        NAMESPACE = 'default'
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Validate Helm Chart') {
            steps {
                container('helm-kubectl') {
                    sh 'helm lint ./my-app-chart'
                }
            }
        }

        stage('Security Scan Manifests') {
            steps {
                container('trivy') {
                    sh 'trivy config ./my-app-chart'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                container('helm-kubectl') {
                    sh '''
                        helm upgrade --install ${HELM_RELEASE_NAME} ./my-app-chart \
                          --namespace ${NAMESPACE} \
                          --timeout 5m
                    '''
                }
            }
        }

        stage('Verify Health') {
            steps {
                container('helm-kubectl') {
                    sh 'kubectl rollout status ${HELM_RELEASE_NAME} -n ${NAMESPACE}'
                }
            }
        }
    }

    post {
        failure {
            container('helm-kubectl') {
                echo 'Deployment Failed! Triggering Rollback...'
                sh 'helm rollback ${HELM_RELEASE_NAME} -n ${NAMESPACE} || true'
            }
        }
        always {
            deleteDir()
        }
    }
}
