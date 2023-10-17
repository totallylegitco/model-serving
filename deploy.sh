#!/bin/bash

set -ex

BASE_IMAGE=holdenk/totallylegitco-modelserving
TAG=0.7
IMAGE="${BASE_IMAGE}:${TAG}"

docker pull "${IMAGE}" || docker buildx build . --platform=linux/arm64,linux/amd64 -t "${IMAGE}" --push

kubectl apply -f serve.yaml
