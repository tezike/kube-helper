#! /bin/bash

kubectl apply -f helm/tiller.yaml
helm init --service-account tiller --wait

kubectl apply -f namespace.yml
helm install stable/prometheus --namespace monitoring --name prometheus

kubectl apply -f grafana/config.yml

helm install stable/grafana -f grafana/values.yml --namespace monitoring --name grafana

# generate wildcard ssl secret
kubectl create secret tls wildcard-certificate-tls -n dev --key="privkey.pem" --cert="fullchain.pem"

# Exposes grana to external source 
kubectl apply -f grafana/ingress.yml

kubectl get secret \
    --namespace monitoring grafana \
    -o jsonpath="{.data.admin-password}" \
    | base64 --decode ; echo

# Install Rabbitmq

helm install --name xend-broker-svc --namespace production --set rabbitmqUsername=admin \
--set rabbitmqErlangCookie=secretcookie \
--set rabbitmqErlangCookie=secretcookie --set rbacEnabled=true --set service.type=NodePort --set ingress.enabled=true \
--set ingress.hostName="devbroker.xen.c" --set ingress.tls=true --set ingress.tlsSecret="wildcard-certificate-tls" stable/rabbitmq-ha