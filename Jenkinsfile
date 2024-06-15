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
    }
  }
}
