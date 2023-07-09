#!/bin/bash

set -ex

#docker buildx build . --platform=linux/arm64,linux/amd64 -t holdenk/totallylegitco-modelserving:0.2a --push
cd serve
serve build model:models -o models_serve.yaml
cd ..

docker buildx build . --platform=linux/amd64 -t holdenk/totallylegitco-modelserving:0.2a --push

kubectl apply -f service.yaml
kubectl apply -f podsa.yaml

# Kind of a hack but during dev this makes it easier.
(helm install --namespace totallylegitco raycluster kuberay/ray-cluster --version 0.5.0 --set image.repository=holdenk/totallylegitco-modelserving --set image.tag=0.2a --set image.pullPolicy=Always --set head.resources.limits.memory=20G  --set head.resources.requests.memory=20G  --set worker.resources.limits.memory=16G  --set worker.resources.requests.memory=16G  && sleep 20) || echo "Reusing existing cluster."

head_node=$(kubectl get pods -n totallylegitco -l ray.io/node-type=head -o=name)
kubectl port-forward --address localhost -n totallylegitco service/raycluster-kuberay-head-svc 8265:8265 &
ui_pfwd_pid=$!
kubectl port-forward --address localhost -n totallylegitco ${head_node} 52365:52365 &
pfwd_pid=$!
cd serve
serve deploy 
cd ..
# kubectl exec -n totallylegitco ${head_node} -- bash -c "cd /apps;python -m serve.main"
