pipeline {
    agent {label "Functional"}

    parameters {
        string(defaultValue: 'EMPTY', description: '', name: 'RELEASE_NUMBER')
        string(defaultValue: 'develop', description: '', name: 'TARGET_BRANCH')
    }

    environment {
        RELEASE_NUMBER="${params.RELEASE_NUMBER}"
        GITHUB_TOKEN=credentials('GITHUB_TOKEN')
        JIRA_CREDS=credentials('JIRA_CREDS')
        BLUEBADGEBOT=credentials('bluebadgebot')
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
                sh '''
                    (curl -LO https://github.com/reaandrew/semverit/archive/master.zip && unzip master.zip && cd semverit-master/ && make dist && mv dist/semverit ../)
                    export PATH=./:$PATH
                    curl -s -o jira_page_ctl -H "Authorization: token ${GITHUB_TOKEN}" -H 'Accept: application/vnd.github.v3.raw' -O -L https://raw.githubusercontent.com/uk-gov-dft/shell-scripts/master/jira_page_ctl
                    chmod +x jira_page_ctl
                    echo -n "$JIRA_CREDS" > jira_creds
                    chmod 600 jira_creds 
                    echo -n "$BLUEBADGEBOT" > confluence_creds
                    pwd
                    ls -la
                    ./cut.sh output
                '''

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
