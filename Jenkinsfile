pipeline {
	agent any
	stages {
		stage ('SCM') {
			steps {
				echo 'checkout SCM'
				}
			}
		stage ('SonarQubeAnalysis') {
			agent {
				label 'maven'
				}
			steps {
				withSonarQubeEnv('sonarserver) {
					sh "mvn clean verify sonar:sonar -Dsonar.projectKey=maven"
					}
				}
			}
		}
	}
