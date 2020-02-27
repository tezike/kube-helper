helm install --name {service_name} --namespace dev --set rabbitmqUsername=admin \
--set rabbitmqErlangCookie=secretcookie \
--set rabbitmqErlangCookie=secretcookie --set rbacEnabled=true --set service.type=NodePort --set ingress.enabled=true \
--set ingress.hostName={name_of_url} --set ingress.tls=true --set ingress.tlsSecret={name_of_secret} stable/rabbitmq-ha

kubectl get secret --namespace production {service_name} -o jsonpath="{.data.rabbitmq-password}" | base64 --decode