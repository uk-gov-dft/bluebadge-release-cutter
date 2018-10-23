pipeline {
    agent {label "Functional"}

    environment {
        GITHUB_TOKEN=credentials('GITHUB_TOKEN')
     }

    stages {
  
        stage('Clone the applications') {
            steps {
                sh 'git clone "https://$GITHUB_TOKEN:x-oauth-basic@github.com/uk-gov-dft/la-webapp.git"'
                sh '. ./semverit && getNextVersion la-webapp'
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
