//A basic Jenkins Pipeline that will install a Maven package on a Linux node
node {
    stage('Github Checkout'){
        git 'https://github.com/ibrolord/my-app.git'
    }
    stage('Run the package'){
        //Get the Maven pipeline syntax from Jenkins pipeline syntax generator. It could be mvnDir depending on your jenkins
       def mvnHome = tool name: 'maven-3', type: 'maven'
        //Get maven home path  with interpolation and "" then Run a build. It could be mvnDir depending on your jenkins
       sh "${mvnHome}/bin/mvn package " 
    }
}



