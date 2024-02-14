#!/usr/bin/env bash

if [ -z "$REDIS_PASSWORD" ]
then
  echo "Environment variable REDIS_PASSWORD has to be provided"
  exit 1
fi

unset USE_KIND
# Check if kubectl is available in the system
if kubectl 2>/dev/null >/dev/null; then
  # Check if kubectl can communicate with a Kubernetes cluster
  if kubectl get nodes 2>/dev/null >/dev/null; then
    echo "Kubernetes cluster is available. Using existing cluster."
    export USE_KIND=0
  else
    echo "Kubernetes cluster is not available. Creating a Kind cluster..."
    export USE_KIND=X
  fi
else
  echo "kubectl is not installed. Please install kubectl to interact with Kubernetes."
  export USE_KIND=X
fi

if [ "X${USE_KIND}" == "XX" ]; then
    # Make sure cluster exists if Mac
    if ! kind get clusters 2>&1 | grep -q "kind-redis"
    then
      envsubst < kind-config.yaml.template > kind-config.yaml
      kind create cluster --config kind-config.yaml --name kind-redis
    fi

    # Make sure create cluster succeeded
    if ! kind get clusters 2>&1 | grep -q "kind-redis"
    then
        echo "Creation of cluster failed. Aborting."
        exit 255
    fi
fi

# add metrics
kubectl apply -f https://dev.ellisbs.co.uk/files/components.yaml

# install local storage
kubectl apply -f  local-storage-class.yml

# create redis namespace, if it doesn't exist
kubectl get ns redis 2> /dev/null
if [ $? -eq 1 ]
then
    kubectl create namespace redis
fi

# create redis secret
kubectl create secret generic redis-password --namespace=redis --from-literal=REDIS_PASSWORD="$REDIS_PASSWORD"

# create deployment
kubectl apply -f redis-deployment.yaml
