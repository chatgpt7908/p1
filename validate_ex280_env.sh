#!/bin/bash

# Function to check if a project exists
check_project() {
  if oc get project $1 &> /dev/null; then
    echo "Project $1: PASS"
  else
    echo "Project $1: FAIL"
  fi
}

# Function to check if a deployment exists
check_deployment() {
  if oc get deployment $1 -n $2 &> /dev/null; then
    echo "Deployment $1 in project $2: PASS"
  else
    echo "Deployment $1 in project $2: FAIL"
  fi
}

# Function to check if a route exists
check_route() {
  if oc get route $1 -n $2 &> /dev/null; then
    echo "Route $1 in project $2: PASS"
  else
    echo "Route $1 in project $2: FAIL"
  fi
}

# Function to check if a secret exists
check_secret() {
  if oc get secret $1 -n $2 &> /dev/null; then
    echo "Secret $1 in project $2: PASS"
  else
    echo "Secret $1 in project $2: FAIL"
  fi
}

# Function to check if a configmap exists
check_configmap() {
  if oc get configmap $1 -n $2 &> /dev/null; then
    echo "ConfigMap $1 in project $2: PASS"
  else
    echo "ConfigMap $1 in project $2: FAIL"
  fi
}

# Function to check if a quota exists
check_quota() {
  if oc get quota $1 -n $2 &> /dev/null; then
    echo "Quota $1 in project $2: PASS"
  else
    echo "Quota $1 in project $2: FAIL"
  fi
}

# Function to check if a limitrange exists
check_limitrange() {
  if oc get limitrange $1 -n $2 &> /dev/null; then
    echo "LimitRange $1 in project $2: PASS"
  else
    echo "LimitRange $1 in project $2: FAIL"
  fi
}

# Function to check if a service account exists
check_serviceaccount() {
  if oc get sa $1 -n $2 &> /dev/null; then
    echo "ServiceAccount $1 in project $2: PASS"
  else
    echo "ServiceAccount $1 in project $2: FAIL"
  fi
}

# Function to check if a cronjob exists
check_cronjob() {
  if oc get cronjob $1 -n $2 &> /dev/null; then
    echo "CronJob $1 in project $2: PASS"
  else
    echo "CronJob $1 in project $2: FAIL"
  fi
}

# Function to check if an HPA exists
check_hpa() {
  if oc get hpa $1 -n $2 &> /dev/null; then
    echo "HPA $1 in project $2: PASS"
  else
    echo "HPA $1 in project $2: FAIL"
  fi
}

# Function to check if a network policy exists
check_networkpolicy() {
  if oc get networkpolicy $1 -n $2 &> /dev/null; then
    echo "NetworkPolicy $1 in project $2: PASS"
  else
    echo "NetworkPolicy $1 in project $2: FAIL"
  fi
}

# Function to check if a must-gather archive exists
check_mustgather() {
  if [ -f $1 ]; then
    echo "Must-gather archive $1: PASS"
  else
    echo "Must-gather archive $1: FAIL"
  fi
}

# Function to check if a bootstrap project template exists
check_bootstrap_template() {
  if oc get template $1 -n openshift-config &> /dev/null; then
    echo "Bootstrap project template $1: PASS"
  else
    echo "Bootstrap project template $1: FAIL"
  fi
}

# Validate each question's environment setup

# Question 1: HTPasswd identity provider
check_project openshift-config
check_secret htpass-secret openshift-config

# Question 2: Cluster permissions
check_project kube-system

# Question 3: Quota in apollo project
check_project apollo
check_quota apollo-quota apollo

# Question 4: LimitRange in titan project
check_project titan
check_limitrange titan-limits titan

# Question 5: Deployment and route in bluewills project
check_project bluewills
check_deployment rocky bluewills
check_route rocky bluewills

# Question 6: Secure route in area51 project
check_project area51
check_deployment oxcart area51
check_route oxcart area51

# Question 7: Scaling in lerna project
check_project lerna
check_deployment hydra lerna

# Question 8: Autoscaling in gru project
check_project gru
check_deployment scala gru
check_hpa scala gru

# Question 9: Secret in math project
check_project math
check_secret magic math

# Question 10: Environment variable in qed deployment
check_project math
check_deployment qed math

# Question 11: Service account in apples project
check_project apples
check_serviceaccount ex280-sa apples

# Question 12: PVC and deployment in space project
check_project space
check_deployment gamma space

# Question 13: CronJob in marathon project
check_project marathon
check_cronjob scaling marathon

# Question 14: Liveness probe in gamma deployment
check_project space
check_deployment gamma space

# Question 15: Network policies in atlas project
check_project atlas
check_networkpolicy deny-all atlas
check_networkpolicy allow-specific atlas

# Question 16: File Integrity operator
check_project openshift-file-integrity

# Question 17: Deployment in path-finder project
check_project path-finder
check_deployment voyager path-finder

# Question 18: Network policies in atlas project
check_project atlas
check_deployment mercury atlas
check_networkpolicy deny-all atlas
check_networkpolicy allow-specific atlas

# Question 19: PV and PVC in space project
check_project space
check_deployment gamma space

# Question 20: Bootstrap project template
check_bootstrap_template project-request

# Question 21: Must-gather archive
check_mustgather /root/ex280-clusterdata.tar.gz

# Question 22: Deployment and route in space project
check_project space
check_deployment gamma space
check_route gamma space

# Save results to a file
exec &> validation_results.txt
