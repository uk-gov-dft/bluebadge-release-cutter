pipeline {
    agent {label "Functional"}

    environment {
        GITHUB_TOKEN=credentials('GITHUB_TOKEN')
        JIRA_CREDS=credentials('JIRA_CREDS')
     }

    stages {
  
        stage('Get the tool') {
            steps {
                sh 'git config --global user.email "dft-buildbot-valtech@does.not.exist"'
                sh 'git config --global user.name "dft-buildbot-valtech"'
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
                  reportDir: 'output',
                  reportFiles: 'RELEASE_NOTES',
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
