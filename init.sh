#! /bin/bash

kubectl apply -f helm/tiller.yaml
helm init --service-account tiller --wait

kubectl apply -f namespace.yml
helm install stable/prometheus --namespace monitoring --name prometheus

kubectl apply -f grafana/config.yml

helm install stable/grafana -f grafana/values.yml --namespace monitoring --name grafana

# Exposes grana to external source 
kubectl apply -f grafana/ingress.yml

kubectl get secret \
    --namespace monitoring grafana \
    -o jsonpath="{.data.admin-password}" \
    | base64 --decode ; echo