#!/bin/bash

# Function to create a project if it doesn't exist
create_project() {
  if ! oc get project $1 > /dev/null 2>&1; then
    oc new-project $1
  fi
}

# Function to deploy a placeholder app
deploy_placeholder_app() {
  oc new-app --name=$1 quay.io/redhattraining/hello-world-nginx -n $2
}

# Create required projects
create_project apollo
create_project titan
create_project gemini
create_project bluebook
create_project apache
create_project bluewills
create_project area51
create_project lerna
create_project gru
create_project math
create_project apples
create_project space
create_project marathon
create_project atlas
create_project path-finder

# Deploy placeholder apps where needed
deploy_placeholder_app rocky bluewills
deploy_placeholder_app oxcart area51
deploy_placeholder_app hydra lerna
deploy_placeholder_app scala gru
deploy_placeholder_app qed math
deploy_placeholder_app oranges apples
deploy_placeholder_app gamma space
deploy_placeholder_app scaling marathon
deploy_placeholder_app mercury atlas
deploy_placeholder_app voyager path-finder

echo "Base environment setup for EX280 practice questions is complete."
