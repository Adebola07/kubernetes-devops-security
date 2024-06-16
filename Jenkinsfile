pipeline {
  agent any

  tools{
        maven 'Mymaven'
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
      post {
      
       always {
          junit 'target/surefire-reports/*.xml'
          jacoco execPattern: 'target/jacoco.exec'
       }
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

    stage('Docker Build and Push') {
      steps {
        script {
         if (env.BUILD_NUMBER <= '16') {
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

  }
}
