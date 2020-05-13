sudo certbot certonly --manual -d *.xend.tk -d xend.tk --agree-tos --no-bootstrap --manual-public-ip-logging-ok --preferred-challenges dns-01 --server https://acme-v02.api.letsencrypt.org/directory


kubectl create secret tls -n production wildcard-certificate-tls --cert fullchain.pem --key privkey.pem