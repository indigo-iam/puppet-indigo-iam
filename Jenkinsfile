#!/usr/bin/env groovy

pipeline {
  agent { label 'generic' }

  options {
    timeout(time: 1, unit: 'HOURS')
    buildDiscarder(logRotator(numToKeepStr: '5'))
  }

  stages {
    stage('analysis'){ 
      when {
          environment name: 'CHANGE_URL', value: ''
      }
      steps {
        script {
          withSonarQubeEnv{
            def sonar_opts="-Dsonar.host.url=${SONAR_HOST_URL} -Dsonar.login=${SONAR_AUTH_TOKEN}"
            sh "/opt/sonar-scanner/bin/sonar-scanner ${sonar_opts}"
          }
        }
      }
    }

    stage('build') {
      steps {
        dir('indigo_iam'){
          sh '/opt/puppetlabs/bin/puppet module build'
        }
      }
    }

    stage('archive') {
      steps {
        dir('indigo_iam/pkg'){
          archiveArtifacts 'cnaf-indigo_iam-*.tar.gz'
        }
      }
    }
    
   stage('result'){
     steps {
       script {
         currentBuild.result = 'SUCCESS'
       }
     }
   }
 }

  post {
    unstable {
      slackSend color: 'danger', message: "${env.JOB_NAME} - #${env.BUILD_NUMBER} Unstable (<${env.BUILD_URL}|Open>)" 
    }

    failure {
      slackSend color: 'danger', message: "${env.JOB_NAME} - #${env.BUILD_NUMBER} Failure (<${env.BUILD_URL}|Open>)" 
    }

    changed {
      script{
        if('SUCCESS'.equals(currentBuild.result)) {
          slackSend color: 'good', message: "${env.JOB_NAME} - #${env.BUILD_NUMBER} Back to normal (<${env.BUILD_URL}|Open>)"
        }
      }
    }
  }
}
