#!/bin/bash

if [ -z "$1" ]; then
echo "SET VERSION IMAGE !!!!!!"
exit 1
fi

source ~/.bashrc
cd ~/diploma_devops/frontend
kubectl delete -f nhl_app_fe.yaml
docker build -t karamel32/nhl_app:$1 .
docker push karamel32/nhl_app:$1
sed -i "s/nhl_app:[0-9]\+\.[0-9]\+\.[0-9]\+/nhl_app:$1/g" nhl_app_fe.yaml
kubectl apply -f nhl_app_fe.yaml
kubectl get ing -w
