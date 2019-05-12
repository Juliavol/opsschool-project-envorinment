# opsschool-midterm
Opsschool 2019 mid-course project

The goal of this project, is to create a full CI/CD process for a web application.

The AWS environment is created using terraform
Terreaform uses ansible to complete the environment configuration

Environment details:
- Jenkins Master - contains the application pipeline (booted with groovy), and uses dynamic slaves on EC2 to run the pipeline
	1. The pipeline clones the application repo
	2. Runs tests
	3. Pushes the new code to dockerhub
	4. Deploys the new container to K8s
- K8s deploys the docker image to 2 minions
- Consul monitors the K8s Nodes.



Usage - terraform apply -var-file terraform.tfvars
