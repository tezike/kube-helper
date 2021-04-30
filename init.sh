#! /bin/bash

kubectl apply -f helm/tiller.yaml
helm init --service-account tiller --wait

kubectl apply -f namespace.yml

kubectl apply -f grafana/config.yml

helm install stable/grafana -f grafana/values.yml --namespace monitoring --name grafana


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

# kubeseal
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.7.0/controller.yaml
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.7.0/sealedsecret-crd.yaml


# generate wildcard ssl secret
kubectl delete secret wildcard-certificate-tls -n production
kubectl delete secret wildcard-certificate-tls -n monitoring
kubectl create secret tls wildcard-certificate-tls -n monitoring --key=privkey.pem --cert=fullchain.pem

kubectl create secret tls wildcard-certificate-tls -n production --key=privkey.pem --cert=fullchain.pem

sudo add-apt-repository ppa:certbot/certbot

sudo apt install python-certbot-nginx

sudo certbot certonly --manual -d *.xend.tk -d xend.tk --agree-tos --no-bootstrap --manual-public-ip-logging-ok --preferred-challenges dns-01 --server https://acme-v02.api.letsencrypt.org/directory

sudo certbot certonly --manual -d *.geena.live -d geena.live --agree-tos --no-bootstrap --manual-public-ip-logging-ok --preferred-challenges dns-01 --server https://acme-v02.api.letsencrypt.org/directory

sudo cp /etc/letsencrypt/live/geena.live/fullchain.pem fullchain.pem

sudo cp /etc/letsencrypt/live/geena.live/privkey.pem privkey.pem


sudo cp /etc/letsencrypt/live/xend.tk/fullchain.pem fullchain.pem

sudo cp /etc/letsencrypt/live/xend.tk/privkey.pem privkey.pem

sudo chmod -R 775 fullchain.pem

sudo chmod -R 775 privkey.pem


kubectl convert -f deployments/staging/setups/deployment.yaml --output-version apps/v1 > deployments/staging/setups/temp.yaml && rm deployments/staging/setups/deployment.yaml && mv deployments/staging/setups/temp.yaml deployments/staging/setups/deployment.yaml