#!/usr/bin/env bash
ZC="zchain_genkeys"
read -p "Provide the docker image tag name: " TAG
read -p "Provide the github organisation name[default:-0chaintest]: " organisation
echo "${organisation:-0chaintest}/${ZC}:$TAG"

if [ -n "$TAG" ]; then
echo " $TAG is the tag name provided"
REGISTRY_IMAGE="${organisation:-0chaintest}/${ZC}"
if [[ $? -ne 0 ]]; then
  docker login
fi

sudo docker build -t ${REGISTRY_IMAGE}:${TAG}  .
sudo docker pull ${REGISTRY_IMAGE}:0miner
sudo docker tag ${REGISTRY_IMAGE}:0miner ${REGISTRY_IMAGE}:0miner_stable_latest
echo "Re-tagging the remote latest tag to 0miner_stable_latest"
sudo docker push ${REGISTRY_IMAGE}:0miner_stable_latest
sudo docker tag ${REGISTRY_IMAGE}:${TAG} ${REGISTRY_IMAGE}:0miner
echo "Pushing the new latest tag to dockerhub"
sudo docker push ${REGISTRY_IMAGE}:0miner
echo "Pushing the new tag to dockerhub tagged as ${REGISTRY_IMAGE}:${TAG}"
sudo docker push ${REGISTRY_IMAGE}:${TAG}
fi