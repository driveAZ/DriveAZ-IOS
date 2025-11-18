pipeline {
    agent {label 'mac-mini-5gen'}
    stages {
        stage('CI/CD') {
            steps {
                sh 'npm install'
                dir('DriveAZ') {
                    sh 'pwd'
                    sh '''
                        #!/bin/bash

                        # Run the command and store the output in a variable
                        output=$(pod repo-art list)

                        # Check if the output contains the string you're looking for
                        if [[ $output == *"b2v-ios-extras"* ]]; then
                          echo “b2v-ios-extras Artifactory has been found“
                        else
                          pod repo-art add b2v-ios-extras https://b2v.jfrog.io/artifactory/api/pods/b2v-ios-extras
                          echo "Installing b2v-ios-extras from Artifactory"
                        fi
                    '''
                    sh 'pod repo update'
                    sh 'pod install'
                    sh 'swiftlint lint --strict --fix'
                    sh 'swiftlint lint --strict'
                    dir('build') {
                        dir('Logs'){
                            dir('Test') {
                                deleteDir()
                            }
                        }
                    }
                    sh "xcodebuild -workspace DriveAZ.xcworkspace -scheme DriveAZ -derivedDataPath Build/ -destination 'platform=iOS Simulator,name=iPhone 12' -enableCodeCoverage YES clean build test CODE_SIGN_IDENTITY='' CODE_SIGNING_REQUIRED=NO"
                    sh 'xcrun xccov view --report build/Logs/Test/*.xcresult --json > testResults.json'
                    sh 'node ../tools/checkTestCoverage.js'
                }
                sh 'npx commitlint --from HEAD~1 --to HEAD --verbose'
            }
        }
    }
    
}
