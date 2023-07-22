#!/bin/bash

set -ex

#docker buildx build . --platform=linux/arm64,linux/amd64 -t holdenk/totallylegitco-modelserving:0.2a --push
cd serve
serve build model:models -o models_serve.yaml
cd ..

# docker buildx build . --platform=linux/amd64 -t holdenk/totallylegitco-modelserving:0.2a --push

kubectl apply -f service.yaml
kubectl apply -f podsa.yaml

# Kind of a hack but during dev this makes it easier.
(helm install --namespace totallylegitco raycluster kuberay/ray-cluster --version 0.5.0 --values ray_cluster_values.yaml && sleep 20) || echo "Reusing existing cluster."
#--set image.repository=holdenk/holdenk/ray-x86-and-l4t --set image.tag=latest --set image.pullPolicy=Always --set head.resources.limits.memory=20G  --set head.resources.requests.memory=20G  --set worker.resources.limits.memory=16G  --set worker.resources.requests.memory=16G --set worker.nodeSelector="node.kubernetes.io/gpu: gpu" --set head.nodeSelector="node.kubernetes.io/gpu: gpu" && sleep 20) || echo "Reusing existing cluster."

sleep 5

head_node=$(kubectl get pods -n totallylegitco -l ray.io/node-type=head -o=name)
while [ kubectl get pod -n totallylegitco $(head_node) | grep Pending ];
      echo "Pod not ready yet."
      sleep 1;
done
kubectl port-forward --address localhost -n totallylegitco service/raycluster-kuberay-head-svc 8265:8265 &
ui_pfwd_pid=$!
kubectl port-forward --address localhost -n totallylegitco ${head_node} 52365:52365 &
pfwd_pid=$!
kubectl port-forward --address localhost -n totallylegitco ${head_node} 6379:6379 &
cd serve
serve start
sleep 1
serve deploy models_serve.yaml
sleep 1
serve status models_serve.yaml
cd ..
# kubectl exec -n totallylegitco ${head_node} -- bash -c "cd /apps;python -m serve.main"
