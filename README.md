# WideBot DevOps Task
Kindly check the Images directory in the repo, it includes a couple of pictures one for the web application up and running with TLS applied and the other is a screenshot for the resources running over Kubernetes (K8s).



# How to replicate my environment?

- clone my repo
```bash
$ git clone https://github.com/Nader-Tarek/widebot-devops-task.git
```
- pick a region and configure your AWS CLI locally
- change the region in the eks.tf file and change the subnet ID's where you need your cluster.
- now we can deploy out first Terraform script
```bash
$ terraform init
$ terraform plan
$ terraform apply
```
- now we would have our K8s cluster up and running
- we need to run this command to be able to interact with it
```bash
$ aws eks update-kubeconfig --name eks-widebot
```
- now we need to install the AWS load balancer controller to be able to let EKS manage the load balancers and attach the TLS cert to it, I followed this doc it's straightforward https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html 
- Next we need to request a public TLS certificate for our domain name ( I did this step manually from the AWS management console) here's a doc for the exact steps I took 
https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request-public.html
- Take the ARN of the TLS certificate and change it under the kubernetes_service resource under the Kubernetes Directory in k8s.tf file.
- (Optional) Add your domain name to an AWS Route53 hosted zone to be able to add the CNAME record for the domain name by terraform. if you won't do this step remove the last aws_route53_record resource from the k8s.tf file.  
- Now our cluster is ready to deploy our web app, we get into the Kubernetes directory where the K8s resources reside and apply them using Terraform.
```bash
$ cd Kubernetes
$ terraform init
$ terraform plan
$ terraform apply
```
- Now we should give the loadbalancer some time to provision then we will be able to access our web app through the domain with TLS enabled.

## All of the decisions I made was based on which is the fastest approach and applied it, there's so much I could improve like using terraform modules and make a project structure to separate different resources (compute, networking, identity, etc...)

### I could not find anything regarding MongoDB and Redis in the web app repository so I did not implement them. (I could easily install them using helm charts but they were useless because the web app is not using them.
