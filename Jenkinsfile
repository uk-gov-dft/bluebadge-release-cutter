pipeline {
    agent {label "Functional"}

    environment {
        GITHUB_TOKEN=credentials('GITHUB_TOKEN')
     }

    stages {
  
        stage('Get the tool') {
            steps {
                sh 'curl -LO https://github.com/reaandrew/semverit/archive/master.zip && unzip master.zip && cd semverit-master/ && make dist && mv dist/semverit ../'
                sh 'git config --global user.email "dft-buildbot-valtech@does.not.exist"'
                sh 'git config --global user.name "dft-buildbot-valtech"'
            }
        }

        stage('Cut la-webapp') {
            steps {
                sh 'git clone "https://$GITHUB_TOKEN:x-oauth-basic@github.com/uk-gov-dft/la-webapp.git"'
                sh './cut.sh ./la-webapp'
            } 
        }

        stage('Cut usermanagement-service') {
            steps {
                sh 'git clone "https://$GITHUB_TOKEN:x-oauth-basic@github.com/uk-gov-dft/usermanagement-service.git"'
                sh './cut.sh ./usermanagement-service'
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
