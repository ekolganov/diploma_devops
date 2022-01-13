#!/bin/bash

if [ -z "$1" ]; then
echo "SET VERSION IMAGE !!!!!!"
exit 1
fi

de_file=deployment-nhl_app_be.yaml

source ~/.bashrc
cd ~/diploma_devops/backend
#kubectl delete -f $de_file
docker build --no-cache -t karamel32/nhl_app_be:$1 .
docker push karamel32/nhl_app_be:$1
sed -i "s/nhl_app_be:[0-9]\+\.[0-9]\+\.[0-9]\+/nhl_app_be:$1/g" $de_file
kubectl apply -f $de_file
kubectl get po -w
