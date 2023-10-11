pipeline {
    agent any

    stages {
        stage('PreBuild') {
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
                    sh 'aws ssm put-parameter --name BUILD_NUMBER --value $BUILD_NUMBER --type String --overwrite'
                }
            }
        }
        stage('Build') {

            agent {
                label 'maven'
              }

            steps {
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
                    sh 'aws s3api put-object --bucket artifacts-jar-test --key spb-jar-files/$BUILD_NUMBER/ --content-length 0'
                    sh 'aws s3 cp target/ s3://artifacts-jar-test/spb-jar-files/$BUILD_NUMBER --recursive --include "*.jar"'
                    sh 'aws s3 cp Dockerfile s3://artifacts-jar-test/spb-jar-files/$BUILD_NUMBER/'
                }
                
            }


        }
        
        stage('Approve BuildImage') {
            steps {
                input message: 'Do you want to build the image?', ok: 'Yes'
            }
        }
        
        stage('Build Image on AWS CodeBuild') {
            steps {
                awsCodeBuild credentialsId: 'code-creds', credentialsType: 'jenkins', projectName: 'docker', region: 'us-east-1', sourceControlType: 'project'
            }
        }
    }
}
