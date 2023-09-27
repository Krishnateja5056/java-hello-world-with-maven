pipeline {
    agent any

    stages {
        stage('Checkout') {
              
            steps {
                
                checkout([$class: 'GitSCM', 
                          branches: [[name: 'master']], 
                          userRemoteConfigs: [[url: 'https://github.com/Krishnateja5056/java-hello-world-with-maven.git']]])
                stash includes: '*', name: 'app'
                stash includes: 'Dockerfile', name: 'dockerfile'
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

        stage('UploadingArtifactsToS3') {

            agent {
                label 'aws'
            }

            steps {

                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]])
                
                 {
                    unstash 'artifact'
                    sh 'aws s3api put-object --bucket krishnat-test-artifacts --key spb-jar-files/$BUILD_NUMBER/ --content-length 0'
                    sh 'aws s3 cp target/ s3://krishnat-test-artifacts/spb-jar-files/$BUILD_NUMBER --recursive --include "*.jar"'
                }
                
            }

        }
        stage('BuildImageAndPushToECR') {

            agent {
                label 'docker-agent'
            }

            steps {

                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]])
                
                 {
                    unstash 'artifact'
                    unstash 'dockerfile'
                    sh '''aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 580741598336.dkr.ecr.us-east-1.amazonaws.com
                            docker build -t test .
                            docker tag test:latest 580741598336.dkr.ecr.us-east-1.amazonaws.com/test:latest.$BUILD_NUMBER
                            docker push 580741598336.dkr.ecr.us-east-1.amazonaws.com/test:latest.$BUILD_NUMBER'''
    
                
            }


        }

    }

}
        
}
