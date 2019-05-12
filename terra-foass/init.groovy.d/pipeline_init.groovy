import jenkins.model.Jenkins
import hudson.plugins.git.*;

def scm = new GitSCM("https://github.com/Juliavol/opsschool-midterm-app.git")
scm.branches = [new BranchSpec("*/master")];
def flowDefinition = new org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition(scm, "Jenkinsfile")

def parent = Jenkins.instance
def job = new org.jenkinsci.plugins.workflow.job.WorkflowJob(parent, "foass-pipeline")
job.definition = flowDefinition
Jenkins.get().add(job, job.name);
