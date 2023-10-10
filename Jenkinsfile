pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM', 
                          branches: [[name: 'master']], 
                          userRemoteConfigs: [[url: 'https://github.com/jabedhasan21/java-hello-world-with-maven.git']]])
                stash includes: '*', name: 'app'
            }
        }
        stage('Build') {
            agent {
                label 'maven'
            }
            steps {
                unstash 'app'
                sh 'mvn clean package'
                stash includes: '**/target/*.jar', name: 'artifact'
            }
            post {
                always {
                    archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true
                }
            }
        }
        stage('Uploading artifacts') {
            agent {
                label 'aws'
            }
            steps {
                withCredentials([
                    [
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-creds',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]
                ]) {
                    unstash 'artifact'
                    sh 'aws s3api put-object --bucket krishnat-test-artifacts --key spb-jar-files/$BUILD_NUMBER/ --content-length 0'
                    sh 'aws s3 cp target/ s3://krishnat-test-artifacts/spb-jar-files/$BUILD_NUMBER --recursive --include "*.jar"'
                }
            }
        }
    }
}
