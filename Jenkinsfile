pipeline {
    agent 

    parameters {
        string(defaultValue: 'develop', description: '', name: 'LA_VERSION')
        string(defaultValue: 'develop', description: '', name: 'UM_VERSION')
        string(defaultValue: 'develop', description: '', name: 'BB_VERSION')
        string(defaultValue: 'develop', description: '', name: 'AP_VERSION')
        string(defaultValue: 'develop', description: '', name: 'AZ_VERSION')
        string(defaultValue: 'develop', description: '', name: 'MG_VERSION')
        string(defaultValue: 'develop', description: '', name: 'RD_VERSION')
        string(defaultValue: 'develop', description: '', name: 'CA_VERSION')
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
        stage('Clone the applications') {
            steps {
                dir('la-webapp') {
                    git url: 'https://$GITHUB_TOKEN:x-oauth-basic@github.com/uk-gov-dft/la-webapp.git'
                }
                dir('usermanagement-service') {
                    git url: 'https://$GITHUB_TOKEN:x-oauth-basic@github.com/uk-gov-dft/usermanagement-service.git'
                }
                dir('badgemanagement-service') {
                    git url: 'https://$GITHUB_TOKEN:x-oauth-basic@github.com/uk-gov-dft/badgemanagement-service.git'
                }
                dir('applications-service') {
                    git url: 'https://$GITHUB_TOKEN:x-oauth-basic@github.com/uk-gov-dft/applications-service.git'
                }
                dir('authorisation-service') {
                    git url: 'https://$GITHUB_TOKEN:x-oauth-basic@github.com/uk-gov-dft/authorisation-service.git'
                }
                dir('message-service') {
                    git url: 'https://$GITHUB_TOKEN:x-oauth-basic@github.com/uk-gov-dft/message-service.git'
                }
                dir('referencedata-service') {
                    git url: 'https://$GITHUB_TOKEN:x-oauth-basic@github.com/uk-gov-dft/referencedata-service.git'
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
