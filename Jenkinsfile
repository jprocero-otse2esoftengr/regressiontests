#!groovy

pipeline {
    agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '1'))
        disableConcurrentBuilds()
    }
    
    parameters {
        choice(name: 'XUMLC', choices: ['jarfiles/xumlc-7.20.0.jar'], description: 'Location of the xUML Compiler')
        choice(name: 'REGTEST', choices: ['jarfiles/RegTestRunner-8.10.5.jar'], description: 'Location of the Regression Test Runner')
        string(name: 'BRIDGE_HOST', defaultValue: 'ec2-52-74-183-0.ap-southeast-1.compute.amazonaws.com', description: 'Bridge host address')
        string(name: 'BRIDGE_USER', defaultValue: 'jprocero', description: 'Bridge username')
        password(name: 'BRIDGE_PASSWORD', defaultValue: 'jprocero', description: 'Bridge password')
        string(name: 'BRIDGE_PORT', defaultValue: '8080', description: 'Bridge port')
        string(name: 'CONTROL_PORT', defaultValue: '21160', description: 'Control port')
    }

    stages {
        stage('Build') {
            steps {
                dir('appendarrayexercise') {
                    bat """
                        echo "Building xUML model..."
                        java -jar ${XUMLC} -uml uml/BuilderUML.xml
                        echo "Build completed successfully"
                    """
                    archiveArtifacts artifacts: 'repository/BuilderUML/BuilderUML.rep'
                }
            }
        }
        stage('Deploy') {
            steps {
                dir('appendarrayexercise') {
                    bat """
                        echo "Deploying to Bridge..."
                        e2ebridge deploy repository/BuilderUML/BuilderUML.rep -h ${BRIDGE_HOST} -u ${BRIDGE_USER} -P ${BRIDGE_PASSWORD} -o overwrite
                        echo "Deployment completed successfully"
                    """
                }
            }
        }
        stage('Test') {
            steps {
                dir('appendarrayexercise') {
                    bat """
                        echo "Running regression tests..."
                        echo "Connecting to Bridge: ${BRIDGE_HOST}:${BRIDGE_PORT}"
                        
                        echo "=== Running Main Test Suite ==="
                        java -jar ${REGTEST} -project BuilderUML -suite "regressiontest/testsuite/testsuite.xml" -logfile test-results-main.xml -host ${BRIDGE_HOST} -port ${BRIDGE_PORT} -username ${BRIDGE_USER} -password ${BRIDGE_PASSWORD}
                        
                        echo "=== Running Valid Employees Tests ==="
                        java -jar ${REGTEST} -project BuilderUML -suite "regressiontest/testsuite/validEmps/testsuite.xml" -logfile test-results-validEmps.xml -host ${BRIDGE_HOST} -port ${BRIDGE_PORT} -username ${BRIDGE_USER} -password ${BRIDGE_PASSWORD}
                        
                        echo "=== Running Blocked Employee Tests ==="
                        java -jar ${REGTEST} -project BuilderUML -suite "regressiontest/testsuite/BlockedEmp/testsuite.xml" -logfile test-results-blockedEmp.xml -host ${BRIDGE_HOST} -port ${BRIDGE_PORT} -username ${BRIDGE_USER} -password ${BRIDGE_PASSWORD}
                        
                        echo "=== Running Position Check Tests ==="
                        java -jar ${REGTEST} -project BuilderUML -suite "regressiontest/testsuite/PositionSc/testsuite.xml" -logfile test-results-positionSc.xml -host ${BRIDGE_HOST} -port ${BRIDGE_PORT} -username ${BRIDGE_USER} -password ${BRIDGE_PASSWORD}
                        
                        echo "=== Running Test Scenarios ==="
                        java -jar ${REGTEST} -project BuilderUML -suite "regressiontest/testsuite/Testscen/testsuite.xml" -logfile test-results-testScen.xml -host ${BRIDGE_HOST} -port ${BRIDGE_PORT} -username ${BRIDGE_USER} -password ${BRIDGE_PASSWORD}
                        
                        echo "=== Running Bridge Connection Tests ==="
                        java -jar ${REGTEST} -project BuilderUML -suite "regressiontest/testsuite/bridgeconn/testsuite.xml" -logfile test-results-bridgeconn.xml -host ${BRIDGE_HOST} -port ${BRIDGE_PORT} -username ${BRIDGE_USER} -password ${BRIDGE_PASSWORD}
                        
                        echo "All regression tests completed successfully!"
                    """
                }
            }
            post {
                always {
                    junit 'appendarrayexercise/test-results-*.xml'
                    archiveArtifacts artifacts: 'appendarrayexercise/test-results-*.xml'
                    archiveArtifacts artifacts: 'appendarrayexercise/regressiontest/.$output/**/*'
                }
            }
        }
    }
    
    post {
        always {
            echo "Pipeline execution completed"
        }
        success {
            echo "Pipeline succeeded!"
        }
        failure {
            echo "Pipeline failed!"
        }
    }
}
