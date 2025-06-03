
#!/bin/bash

# Log in as kubeadmin
oc login -u kubeadmin -p XxoiQ-9PZjt-Jea2a-iRiKU https://api.ocp4.example.com:6443

# Install httpd-tools
yum install httpd-tools -y

# Create projects
oc new-project apollo
oc new-project titan
oc new-project gemini
oc new-project bluebook
oc new-project apache
oc new-project area51
oc new-project lerna
oc new-project gru
oc new-project math
oc new-project apples
oc new-project path-finder
oc new-project space
oc new-project marathon
oc new-project charts-development
oc new-project atlas

# Create HTPasswd Identity Provider
htpasswd -c -b -B htpassfile jobs deluges
htpasswd -b -B htpassfile wozniak grannies
htpasswd -b -B htpassfile collins culverins
htpasswd -b -B htpassfile adlerin artiste
htpasswd -b -B htpassfile armstrong spacesuits
oc create secret generic htpass-idp-ex280 --from-file=htpasswd=htpassfile -n openshift-config
oc get -o yaml oauth cluster > oauth.yaml
sed -i '/identityProviders:/a - name: ex280-htpasswd
  mappingMethod: claim
  type: HTPasswd
  htpasswd:
    fileData:
      name: htpass-idp-ex280' oauth.yaml
oc replace -f oauth.yaml

# Configure Cluster permissions
oc adm policy add-cluster-role-to-user cluster-admin jobs
oc adm policy add-cluster-role-to-user self-provisioner wozniak
oc adm policy remove-cluster-role-from-group self-provisioner system:authenticated:oauth
oc delete secret kubeadmin -n kube-system

# Configure Project permissions
oc policy add-role-to-user admin armstrong -n apollo
oc policy add-role-to-user admin armstrong -n titan
oc policy add-role-to-user view collins -n apollo

# Create Groups and configure permissions
oc adm groups new commander
oc adm groups new pilot
oc adm groups add-users commander wozniak
oc adm groups add-users pilot adlerin
oc policy add-role-to-group edit commander -n apache
oc policy add-role-to-group edit commander -n gemini
oc policy add-role-to-group view pilot -n apache

# Configure Quotas for the Project
oc project apache
oc create quota ex280-quota --hard limits.memory=1Gi,limits.cpu=2,replicationcontrollers=3,pods=3,services=6

# Configure Limits for the Project
oc project bluebook
cat <<EOF > ex280-quotalimit.yaml
apiVersion: "v1"
kind: "LimitRange"
metadata:
  name: "ex280-quotalimit"
spec:
  limits:
    - type: "Pod"
      max:
        cpu: "500m"
        memory: "300Mi"
      min:
        cpu: "10m"
        memory: "100Mi"
    - type: "Container"
      max:
        cpu: "500m"
        memory: "300Mi"
      min:
        cpu: "10m"
        memory: "100Mi"
      defaultRequest:
        cpu: "100m"
        memory: "100Mi"
EOF
oc create -f ex280-quotalimit.yaml

# Deploy applications
oc new-app --name=rocky quay.io/redhattraining/hello-openshift -n bluewills
oc expose svc rocky --hostname=rocky.apps.ocp4.example.com -n bluewills

# Deploy secure route
oc new-app --name=oxcart quay.io/redhattraining/hello-world-nginx -n area51
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj "/C=US/ST=NC/L=Raleigh/O=RedHat/OU=RHT/CN=oxcart.apps.ocp4.example.com" -keyout oxcart.key -out oxcart.crt
oc create route edge --service=oxcart --cert=oxcart.crt --key=oxcart.key --hostname=oxcart.apps.ocp4.example.com -n area51

# Scale the application manually
oc scale --replicas=5 deployment.apps/hydra -n lerna

# Configure Autoscaling for an Application
oc autoscale --min=6 --max=40 --cpu-percent=60 deployment.apps/scala -n gru
oc set resources --requests=cpu=25m --limits=cpu=100m deployment.apps/scala -n gru

# Configure a Secret
oc create secret generic magic --from-literal=Decoder_Ring=ASDA142hfh-gfrhhueo-erfdk345v -n math

# Use the Secret value for Application Deployment
oc set env --from=secret/magic deployment.apps/qed -n math

# Configure a Service Account
oc create serviceaccount ex-280-sa -n apples
oc adm policy add-scc-to-user anyuid -z ex-280-sa -n apples

# Deploy an application using Service Account
oc new-app --name=oranges quay.io/redhattraining/hello-world-nginx -n apples
oc set serviceaccount deployment.apps/oranges ex-280-sa -n apples

# Deploy an application
oc new-app --name=voyager quay.io/redhattraining/hello-world-nginx -n path-finder

# Configure Persistent Storage
oc new-app --name=gamma --image=quay.io/redhattraining/hello-world-nginx -n space
cat <<EOF > gamma-pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: gamma-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Delete
  nfs:
    path: /exports-ocp4
    server: 192.168.50.254
EOF
oc create -f gamma-pv.yaml
cat <<EOF > gamma-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: gamma-pvc
  namespace: space
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
EOF
oc create -f gamma-pvc.yaml
oc set volumes deployment/gamma --add --type=pvc --claim-name=gamma-pvc --mount-path=/srv -n space

# Install Operator
oc create namespace openshift-file-integrity
oc apply -f https://raw.githubusercontent.com/openshift/file-integrity-operator/master/deploy/olm-catalog/file-integrity-operator/manifests/file-integrity-operator.clusterserviceversion.yaml -n openshift-file-integrity

# Deploy a cronjob
oc create cronjob scaling --image=quay.io/redhattraining/scaling --schedule="5 4 2 * *" -n marathon
oc create serviceaccount ex280-ocpsa -n marathon
oc adm policy add-cluster-role-to-user cluster-admin -z ex280-ocpsa -n marathon
oc set serviceaccount cronjob/scaling ex280-ocpsa -n marathon

# Deploy Helm chart
helm repo add ex280-repo http://helm.ocp4.example.com/charts
helm install etherpad ex280-repo/etherpad -n charts-development

# Bootstrap Project template
oc adm create-bootstrap-project-template -o yaml > proj-temp.yaml
cat <<EOF >> proj-temp.yaml
- apiVersion: v1
  kind: ResourceQuota
  metadata:
    name: ${PROJECT_NAME}-quota
  spec:
    hard:
      limits.cpu: "4"
      limits.memory: 4Gi
      pods: "10"
      requests.cpu: "2"
      requests.memory: 1Gi
- apiVersion: v1
  kind: LimitRange
  metadata:
    name: ${PROJECT_NAME}-limitrange
  spec:
    limits:
      - type: Container
        default:
          cpu: "100m"
          memory: "100Mi"
        defaultRequest:
          cpu: "30m"
          memory: "30Mi"
EOF
oc create -f proj-temp.yaml -n openshift-config
oc edit projects.config.openshift.io/cluster

# Monitoring and health-check
oc adm must-gather --dest-dir=/root/ex280-clusterdata
tar -zcvf /root/ex280-clusterdata.tar.gz /root/ex280-clusterdata
oc set probe --liveness --open-tcp=8080 --initial-delay-seconds=3 --timeout-seconds=10 deployment.apps/gamma -n space

# Network Policy
oc new-app --name=mercury quay.io/redhattraining/hello-world-nginx -n atlas
cat <<EOF > deny-all.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: atlas
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress
  ingress: []
  egress: []
EOF
oc create -f deny-all.yaml -n atlas
cat <<EOF > allow-specific.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-specific
  namespace: atlas
spec:
  podSelector:
    matchLabels:
      deployment: mercury
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector: {}
          namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: bluewills
      ports:
        - protocol: TCP
          port: 8080
EOF
oc create -f allow-specific.yaml -n atlas
