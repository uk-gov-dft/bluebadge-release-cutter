pipeline {
    agent any

    parameters {
        string(name: 'LA_VERSION')
        string(name: 'UM_VERSION')
        string(name: 'BB_VERSION')
        string(name: 'AP_VERSION')
        string(name: 'AZ_VERSION')
        string(name: 'MG_VERSION')
        string(name: 'RD_VERSION')
        string(name: 'CA_VERSION')
    }

    environment {
        LA_VERSION="${params.LA_VERSION}"
        UM_VERSION="${params.UM_VERSION}"
        BB_VERSION="${params.BB_VERSION}"
        AP_VERSION="${params.AP_VERSION}"
        AZ_VERSION="${params.AZ_VERSION}"
        MG_VERSION="${params.MG_VERSION}"
        RD_VERSION="${params.RD_VERSION}"
        CA_VERSION="${params.CA_VERSION}"

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
