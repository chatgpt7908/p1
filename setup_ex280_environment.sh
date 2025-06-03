
#!/bin/bash

# Login to OpenShift
oc login -u kubeadmin -p XxoiQ-9PZjt-Jea2a-iRiKU https://api.ocp4.example.com:6443

# Create projects
oc new-project area51
oc new-project space
oc new-project math
oc new-project apples
oc new-project bluewills
oc new-project lerna
oc new-project gru
oc new-project czech
oc new-project path-finder
oc new-project atlas
oc new-project marathon
oc new-project charts-development

# Create service accounts
oc create serviceaccount ex-280-sa -n apples
oc create serviceaccount ex280-ocpsa -n marathon

# Create secrets
oc create secret generic magic --from-literal=Decoder_Ring=ASDA142hfh-gfrhhueo-erfdk345v -n math

# Create configmaps
oc create configmap ex280-cm --from-literal=RESPONSE='six czech cricket critics' -n czech

# Create quotas
oc create quota ex280-quota --hard limits.memory=1Gi,limits.cpu=2,replicationcontrollers=3,pods=3,services=6 -n apache

# Create limit ranges
cat <<EOF | oc create -f - -n bluebook
apiVersion: v1
kind: LimitRange
metadata:
  name: ex280-quotalimit
spec:
  limits:
  - type: Pod
    max:
      cpu: 500m
      memory: 300Mi
    min:
      cpu: 10m
      memory: 100Mi
  - type: Container
    max:
      cpu: 500m
      memory: 300Mi
    min:
      cpu: 10m
      memory: 100Mi
    defaultRequest:
      cpu: 100m
      memory: 100Mi
EOF

# Create PV and PVC
cat <<EOF | oc create -f - -n space
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

cat <<EOF | oc create -f - -n space
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: gamma-pvc
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
EOF

# Deploy applications
oc new-app --name=oxcart quay.io/redhattraining/hello-world-nginx -n area51
oc new-app --name=gamma quay.io/redhattraining/hello-world-nginx -n space
oc new-app --name=qed quay.io/redhattraining/hello-world-nginx -n math
oc new-app --name=oranges quay.io/redhattraining/hello-world-nginx -n apples
oc new-app --name=rocky quay.io/redhattraining/hello-world-nginx -n bluewills
oc new-app --name=hydra quay.io/redhattraining/hello-world-nginx -n lerna
oc new-app --name=scala quay.io/redhattraining/hello-world-nginx -n gru
oc new-app --name=ernie quay.io/redhattraining/hello-world-nginx -n czech
oc new-app --name=voyager quay.io/redhattraining/hello-world-nginx -n path-finder
oc new-app --name=mercury quay.io/redhattraining/hello-world-nginx -n atlas
oc new-app --name=scaling quay.io/redhattraining/scaling -n marathon

# Expose routes
oc expose svc oxcart --hostname=oxcart.apps.ocp4.example.com -n area51
oc expose svc gamma --hostname=space.apps.ocp4.example.com -n space
oc expose svc qed --hostname=qed.apps.ocp4.example.com -n math
oc expose svc oranges --hostname=oranges.apps.ocp4.example.com -n apples
oc expose svc rocky --hostname=rocky.apps.ocp4.example.com -n bluewills
oc expose svc ernie --hostname=ernie.apps.ocp4.example.com -n czech
oc expose svc voyager --hostname=voyager.apps.ocp4.example.com -n path-finder
oc expose svc mercury --hostname=mercury.apps.ocp4.example.com -n atlas

# Set service account for deployment
oc set serviceaccount deployment.apps/oranges ex-280-sa -n apples
oc set serviceaccount cronjob/scaling ex280-ocpsa -n marathon

# Set volume for deployment
oc set volume deployment/gamma --add --type pvc --claim-name=gamma-pvc --mount-path=/srv -n space

# Set environment variables from secret and configmap
oc set env --from secret/magic deployment.apps/qed -n math
oc set env --from configmap/ex280-cm deployment.apps/ernie -n czech

# Set probes
oc set probe deployment.apps/gamma --liveness --open-tcp=8080 --initial-delay-seconds=3 --timeout-seconds=10 -n space

# Scale applications
oc scale deployment.apps/hydra --replicas=5 -n lerna
oc autoscale deployment.apps/scala --min=6 --max=40 --cpu-percent=60 -n gru
oc set resources deployment.apps/scala --requests=cpu=25m --limits=cpu=100m -n gru

# Create network policies
cat <<EOF | oc create -f - -n atlas
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress: []
  egress: []
EOF

cat <<EOF | oc create -f - -n atlas
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-specific
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

# Create cronjob
cat <<EOF | oc create -f - -n marathon
apiVersion: batch/v1
kind: CronJob
metadata:
  name: scaling
spec:
  schedule: "5 4 2 * *"
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: ex280-ocpsa
          containers:
          - name: scaling
            image: quay.io/redhattraining/scaling
          restartPolicy: OnFailure
EOF

# Create bootstrap project template
cat <<EOF | oc create -f - -n openshift-config
apiVersion: template.openshift.io/v1
kind: Template
metadata:
  name: project-request
objects:
- apiVersion: project.openshift.io/v1
  kind: Project
  metadata:
    annotations:
      openshift.io/description: ${PROJECT_DESCRIPTION}
      openshift.io/display-name: ${PROJECT_DISPLAYNAME}
      openshift.io/requester: ${PROJECT_REQUESTING_USER}
    name: ${PROJECT_NAME}
- apiVersion: rbac.authorization.k8s.io/v1
  kind: RoleBinding
  metadata:
    name: admin
    namespace: ${PROJECT_NAME}
  roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: ClusterRole
    name: admin
  subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: ${PROJECT_ADMIN_USER}
- apiVersion: v1
  kind: ResourceQuota
  metadata:
    creationTimestamp: null
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
        cpu: 100m
        memory: 100Mi
      defaultRequest:
        cpu: 30m
        memory: 30Mi
parameters:
- name: PROJECT_NAME
- name: PROJECT_DISPLAYNAME
- name: PROJECT_DESCRIPTION
- name: PROJECT_ADMIN_USER
- name: PROJECT_REQUESTING_USER
EOF

# Edit cluster configuration to use the new project template
oc edit projects.config.openshift.io/cluster
