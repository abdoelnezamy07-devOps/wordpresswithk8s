End-to-End Cloud-Native DevOps Pipeline on AWS & Kubernetes

steps:
  create: 
    1- aws user account with Ec2 full permission
    2- access key and secret access key
    3- Ec2 master node, 2 worker nodes with public access
    4- ebs and efs policy  and attach it to all Ec2
  ssh:
    ssh command from console aws to master node
  ansible:
   prepare_env
     1- pip install ansible kubernetes
     2- after create aws_ec2.yaml, ansible.cfg
     3- ansible-playbook 
	  1- k8s_setup.yaml
     	  2- Join_worker_nodes.yaml
	  3- Install_Helm_*.yaml
	  4- install_jenkins_prometheus.yaml(With_custom_values_file)
     CLI: kubectl get po --all-namespaces
	all pods are running
	  kubectl get svc pvc pv sc -n (namespaces)
   

  helm: 
    install (release_name) your_path_chart
     kubectl get po 
      all pods are running
  deploy:
    with Jenkins:
      create Jenkinsfile and did some configure between github (webhook) and jenkins plugins
    with github actions:
      create in local device/machine .github/workflows directory 
	mkdir -p .github/workflows
	vim deploy.yaml (CI/CD) workflow
      but first in cluster:
	  create service account, role, role_binding and secret with yaml files 
	  config_file to put in secret in github actions
	    contains:
		SA_TOKEN=$(kubectl get secret github-actions-sa-token -n default -o jsonpath='{.data.token}' | base64 --decode)
		CA_CERT=$(kubectl get secret github-actions-sa-token -n default -o jsonpath='{.data.ca\.crt}')
