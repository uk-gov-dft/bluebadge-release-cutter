pipeline {
    agent {label "Functional"}

    parameters {
        string(defaultValue: 'EMPTY', description: '', name: 'RELEASE_NUMBER')
    }

    environment {
        RELEASE_NUMBER="${params.RELEASE_NUMBER}"
        GITHUB_TOKEN=credentials('GITHUB_TOKEN')
        JIRA_CREDS=credentials('JIRA_CREDS')
     }

    stages {
  
        stage('Get the tool') {
            steps {
                sh 'git config --global user.email "dft-buildbot-valtech@does.not.exist"'
                sh 'git config --global user.name "dft-buildbot-valtech"'
                sh 'git config --global push.default matching'
            }
        }

        stage('Release Cut') {
            steps {
                sh 'curl -LO https://github.com/reaandrew/semverit/archive/master.zip && unzip master.zip && cd semverit-master/ && make dist && mv dist/semverit ../'
                sh 'export PATH=./:$PATH'
                sh './cut.sh output'
                publishHTML (target: [
                  allowMissing: false,
                  alwaysLinkToLastBuild: false,
                  keepAll: true,
                  reportDir: '.',
                  reportFiles: 'RELEASE_NOTES.html',
                  reportName: "Release Notes"
                ])
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
