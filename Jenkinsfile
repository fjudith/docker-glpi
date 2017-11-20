// 
// https://github.com/jenkinsci/pipeline-model-definition-plugin/wiki/Syntax-Reference
// https://jenkins.io/doc/book/pipeline/syntax/#parallel
// https://jenkins.io/doc/book/pipeline/syntax/#post
pipeline {
    agent any
    environment {
        REPO = 'fjudith/glpi'
        PRIVATE_REPO = "${PRIVATE_REGISTRY}/${REPO}"
        DOCKER_PRIVATE = credentials('docker-private-registry')
    }
    stages {
        stage ('Checkout') {
            steps {
                script {
                    COMMIT = "${GIT_COMMIT.substring(0,8)}"

                    if ("${BRANCH_NAME}" == "master"){
                        TAG   = "latest"
                        NGINX = "nginx"
                        FPM   = "fpm"
                    }
                    else {
                        TAG   = "${BRANCH_NAME}"
                        NGINX = "${BRANCH_NAME}-nginx"
                        FPM   = "${BRANCH_NAME}-fpm"                     
                    }
                }
                sh 'printenv'
            }
        }
        stage ('Docker build Monolith') {
            agent { label 'docker'}
            steps {
                sh "docker build -f ./Dockerfile -t ${REPO}:${COMMIT} ./"
            }
            post {
                success {
                    echo 'Tag for private registry'
                    sh "docker tag ${REPO}:${COMMIT} ${PRIVATE_REPO}:${TAG}"
                }
            }
        }
        stage ('Run'){
            parallel {
                stage ('Monolith'){
                    agent { label 'docker' }
                    steps {
                        // Create Network
                        sh "docker network create glpi-mono-${BUILD_NUMBER}"
                        // Start database
                        sh "docker run -d --name 'mysql-${BUILD_NUMBER}' -e MYSQL_ROOT_PASSWORD=glpi -e MYSQL_USER=glpi -e MYSQL_PASSWORD=glpi -e MYSQL_DATABASE=glpi --network glpi-mono-${BUILD_NUMBER} amd64/mysql:5.6"
                        sleep 15
                        // Start application
                        sh "docker run -d --name 'glpi-${BUILD_NUMBER}' --link mysql-mono-${BUILD_NUMBER}:mysql --network glpi-mono-${BUILD_NUMBER} ${REPO}:${COMMIT}"
                        // Get container ID
                        script{
                            DOCKER_GLPI    = sh(script: "docker ps -qa -f ancestor=${REPO}:${COMMIT}", returnStdout: true).trim()
                        }
                    }
                }
            }
        }
        stage ('Test'){
            parallel {
                stage ('Monolith'){
                    agent { label 'docker' }
                    steps {
                        sleep 20
                        sh "docker run --rm --network glpi-mono-${BUILD_NUMBER} blitznote/debootstrap-amd64:17.04 bash -c 'curl -i -X GET http://${DOCKER_GLPI}:80'"
                    }
                    post {
                        always {
                            echo 'Remove mono stack'
                            sh "docker rm -fv glpi-${BUILD_NUMBER}"
                            sh "docker rm -fv mysql-${BUILD_NUMBER}"
                            sleep 10
                            sh "docker network rm glpi-mono-${BUILD_NUMBER}"
                        }
                        success {
                            sh "docker login -u ${DOCKER_PRIVATE_USR} -p ${DOCKER_PRIVATE_PSW} ${PRIVATE_REGISTRY}"
                            sh "docker push ${PRIVATE_REPO}:${TAG}"
                        }
                    }
                }
            }
        }
    }
    post {
        always {
            echo 'Run regardless of the completion status of the Pipeline run.'
        }
        changed {
            echo 'Only run if the current Pipeline run has a different status from the previously completed Pipeline.'
        }
        success {
            echo 'Only run if the current Pipeline has a "success" status, typically denoted in the web UI with a blue or green indication.'

        }
        unstable {
            echo 'Only run if the current Pipeline has an "unstable" status, usually caused by test failures, code violations, etc. Typically denoted in the web UI with a yellow indication.'
        }
        aborted {
            echo 'Only run if the current Pipeline has an "aborted" status, usually due to the Pipeline being manually aborted. Typically denoted in the web UI with a gray indication.'
        }
    }
}
