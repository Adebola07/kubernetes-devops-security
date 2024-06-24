pipeline {
  agent any

  tools{
        maven 'Mymaven'
    }

   environment {
    deploymentName = "devsecops"
    containerName = "devsecops-container"
    serviceName = "devsecops-svc"
    imageName = "adebola07/flaskapp:${BUILD_NUMBER}"
    applicationURL="http://68.183.217.216:31432/"
    applicationURI="/increment/99"
  }

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archiveArtifacts artifacts: 'target/*.jar', followSymlinks: false
            }
        }   
      stage('Unit Tests - JUnit and JaCoCo') {
      steps {
        sh "mvn test"
      } 
    }

    stage('Mutation Tests - PIT') {
      steps {
        sh "mvn org.pitest:pitest-maven:mutationCoverage"
      }
      post {
         always {
             pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
         }
      }
    }

    stage('sonarqube-SAST') {
        steps {
            withSonarQubeEnv('Mysonar') {
                sh "mvn clean verify sonar:sonar -Dsonar.projectKey=maven-project -Dsonar.projectName='maven-project'"
           }
           
           timeout(time:2, unit:'MINUTES'){
                script {
                    waitForQualityGate abortPipeline: true
                }
           }
        }
    }

    stage('Vulnerability Scan - Docker') {
          parallel {
              stage ('dependency check') {
                  steps {
                      sh "mvn dependency-check:check"
                  }
              }
              stage ('trivy scan') {
                   steps {
                      sh "bash trivy-docker-image-scan.sh"

                  }
              }
             stage ('OPA-Dockerfile scan for vulnerability') {
                  steps {
                     sh 'docker run --rm -v /var/lib/docker/volumes/jenkins_home/_data/workspace/DevSecops-pipeline:/project openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile'
                  }
             }
          }
   }

    stage('Docker Build and Push') {
      steps {
        script {
         if (env.BUILD_NUMBER <= "16") {
                  sh 'echo skipping'
         }
         else {
          withDockerRegistry([credentialsId: "dockerhub", url: ""]) {
          sh "docker build -t adebola07/flaskapp:${BUILD_NUMBER} ."
          sh "docker push adebola07/flaskapp:${BUILD_NUMBER}"
          }
        }
      }
    }
    }

   stage ('k8s-security-scan-for-vulnerability'){
       parallel {
           stage ('opa-k8s-scan') {
               steps { 
               sh 'docker run --rm -v /var/lib/docker/volumes/jenkins_home/_data/workspace/DevSecops-pipeline:/project openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
               }
           }
           stage('kubesec-k8s-scan') {
               steps {
               sh "bash kubesec-scan.sh"
               }
           }
       }

   }

   stage ('k8s-deployment'){
      steps {
          script {
           withKubeConfig([credentialsId: 'kubeconfig']) {
             sh "bash k8s-deployment-script.sh"
           }
         }
      }
   }

   stage ('k8s-deployment-status-update'){
      steps {
          script {
           withKubeConfig([credentialsId: 'kubeconfig']) {
             sh "bash k8s-deployment-rollout-status.sh"
           }
         }
      }
   }


  }
  post {
    always {
       junit 'target/surefire-reports/*.xml'
       jacoco execPattern: 'target/jacoco.exec'
     
       dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'

    }
  }
}
