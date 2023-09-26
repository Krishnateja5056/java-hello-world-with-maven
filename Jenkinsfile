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

                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]])
                
                 {
                    unstash 'artifact'
                    sh '''  cd target
                            ls
                            pwd
                            aws s3 ls '''
                    sh 'aws s3 cp target/ s3://krishna-test-artifacts/spb-jar-files/ --recursive --include "*.jar"'
                }
                
            }


        }
    }
}
