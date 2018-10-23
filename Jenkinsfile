pipeline {
    agent {label "Functional"}

    environment {
        GITHUB_TOKEN=credentials('GITHUB_TOKEN')
     }

    stages {

        stage('Test Scripts') {
          steps {
            sh 'make test'
          }
        }
  
        stage('Clone the applications') {
            steps {
                sh 'git clone "https://$GITHUB_TOKEN:x-oauth-basic@github.com/uk-gov-dft/la-webapp.git"'
                dir('la-webapp') {
                    sh '. ../semverit && getNextVersion $(pwd)'
                }
            } 
        }
    }

    post {
        always {
            echo 'I finished!'
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
