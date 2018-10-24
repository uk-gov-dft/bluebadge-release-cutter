pipeline {
    agent {label "Functional"}

    environment {
        GITHUB_TOKEN=credentials('GITHUB_TOKEN')
     }

    stages {
  
        stage('Clone the applications') {
            steps {
                sh 'curl -LO https://github.com/reaandrew/semverit/archive/master.zip && unzip master.zip && cd semverit-master/ && make dist && mv dist/semverit ../'
                sh 'git clone "https://$GITHUB_TOKEN:x-oauth-basic@github.com/uk-gov-dft/la-webapp.git"'
                sh 'pwd'
                sh 'realpath ./la-webapp'
                sh './semverit $(realpath ./la-webapp)'
            } 
        }
    }

    post {
        always {
          cleanWs()
        }
        success {
            echo 'I succeeeded!'
        }
        unstable {
            echo 'I am unstable :/'
        }
        failure {
            echo 'I failed :('
        }
        changed {
            echo 'Things were different before...'
        }
    }
}
