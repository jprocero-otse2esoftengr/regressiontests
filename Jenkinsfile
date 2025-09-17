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
                        echo "Checking if Bridge CLI is available..."
                        
                        where e2ebridge >nul 2>&1
                        if %errorlevel% neq 0 (
                            echo "Bridge CLI not found. Installing Bridge CLI..."
                            npm install -g e2e-bridge-cli
                            if %errorlevel% neq 0 (
                                echo "Failed to install Bridge CLI. Skipping deployment."
                                echo "Please install Bridge CLI manually on Jenkins agent: npm install -g e2e-bridge-cli"
                                exit /b 0
                            )
                        )
                        
                        echo "Bridge CLI found. Deploying to Bridge..."
                        e2ebridge deploy repository/BuilderUML/BuilderUML.rep -h ${BRIDGE_HOST} -u ${BRIDGE_USER} -P ${BRIDGE_PASSWORD} -o overwrite
                        if %errorlevel% neq 0 (
                            echo "Deployment failed. Check Bridge server connection and credentials."
                            exit /b 1
                        )
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
                        
                        echo "Checking if Bridge server is accessible..."
                        where e2ebridge >nul 2>&1
                        if %errorlevel% neq 0 (
                            echo "Bridge CLI not available. Installing..."
                            npm install -g e2e-bridge-cli
                        )
                        
                        echo "Testing Bridge connectivity..."
                        e2ebridge services -h ${BRIDGE_HOST} -p ${BRIDGE_PORT} -u ${BRIDGE_USER} -P ${BRIDGE_PASSWORD} >nul 2>&1
                        if %errorlevel% neq 0 (
                            echo "Warning: Cannot connect to Bridge server. Tests may fail."
                            echo "Bridge Host: ${BRIDGE_HOST}:${BRIDGE_PORT}"
                            echo "Continuing with tests anyway..."
                        ) else (
                            echo "Bridge server is accessible. Proceeding with tests..."
                        )
                        
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
                        
                        echo "All regression tests completed!"
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
