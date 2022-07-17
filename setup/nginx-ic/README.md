# Run this before Deploying NGINX-plus. 

** Replace JWT_token with the actual token. JWT token is required to be aloowed to download NGINX-Plus for the NGINX public repository
 

kubectl create secret docker-registry regcred --docker-server=private-registry.nginx.com --docker-username=JWT_token --docker-password=none -n nginx-ingress
