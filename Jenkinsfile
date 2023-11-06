@Library('tfc-lib') _

flags = gitParseFlags()

dockerConfig = getDockerConfig(['MATLAB'], matlabHSPro=false)
dockerConfig.add("-e MLRELEASE=R2022b")
dockerHost = 'docker'

////////////////////////////

hdlBranches = ['master']

stage("Build Toolbox") {
    dockerParallelBuild(hdlBranches, dockerHost, dockerConfig) { 
	branchName ->
	try {
		    checkout scm
	        sh 'git submodule update --init'
		    sh 'pip3 install -r ./CI/gen_doc/requirements_doc.txt'
		    sh 'make -C ./CI/gen_doc doc_ml'
		    sh 'make -C ./CI/scripts build'
		    sh 'make -C ./CI/scripts gen_tlbx'
        } catch(Exception ex) {
			unstable('Development Build Failed')
        }
    }
}

/////////////////////////////////////////////////////

