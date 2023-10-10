pipeline {
    agent any

    parameters {
        choice(name: 'BuildImage', choices: ['Yes', 'No'], description: 'Do you want to build the docker image?')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM', 
                          branches: [[name: 'master']], 
                          userRemoteConfigs: [[url: 'https://github.com/Krishnateja5056/java-hello-world-with-maven.git']]])
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
                    archiveArtifacts artifacts: '**/target/*.jar', allowEmptyArchive: true
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
                    sh 'aws s3api put-object --bucket artifacts-s3-mvn-jarfiles --key spb-jar-files/$BUILD_NUMBER/ --content-length 0'
                    sh 'aws s3 cp target/ s3://artifacts-s3-mvn-jarfiles/spb-jar-files/$BUILD_NUMBER --recursive --include "*.jar"'
                }
            }
        }

        stage('Build Image') {
            when {
                expression { params.BuildImage == 'Yes' }
            }
            agent {
                label 'ecs'
            }
            steps {
                echo "Building the Docker Image"
            }
        }
    }
}
