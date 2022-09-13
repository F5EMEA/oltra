sed -i 's/namespace: nginx/namespace: nginx1/' nginx1/rbac/ns-and-sa.yaml
sed -i 's/namespace: nginx/namespace: nginx2/' nginx2/rbac/ns-and-sa.yaml
sed -i '1, 5d' nginx1/rbac/ns-and-sa.yaml
sed -i '1, 5d' nginx2/rbac/ns-and-sa.yaml

sed -i 's/namespace: nginx/namespace: nginx1/' nginx1/rbac/ap-rbac.yaml
sed -i 's/namespace: nginx/namespace: nginx2/' nginx2/rbac/ap-rbac.yaml
sed -i '1, 16d' nginx1/rbac/ap-rbac.yaml
sed -i '1, 16d' nginx2/rbac/ap-rbac.yaml
sed -i '4s/name: nginx-ingress-app-protect/name: nginx-ingress-app-protect-nginx1/' nginx1/rbac/ap-rbac.yaml
sed -i '4s/name: nginx-ingress-app-protect/name: nginx-ingress-app-protect-nginx2/' nginx2/rbac/ap-rbac.yaml

sed -i 's/namespace: nginx/namespace: nginx1/' nginx1/rbac/apdos-rbac.yaml
sed -i 's/namespace: nginx/namespace: nginx2/' nginx2/rbac/apdos-rbac.yaml
sed -i '1, 16d' nginx1/rbac/apdos-rbac.yaml
sed -i '1, 16d' nginx2/rbac/apdos-rbac.yaml
sed -i '4s/name: nginx-ingress-app-protect-dos/name: nginx-ingress-app-protect-dos-nginx1/' nginx1/rbac/apdos-rbac.yaml
sed -i '4s/name: nginx-ingress-app-protect-dos/name: nginx-ingress-app-protect-dos-nginx2/' nginx2/rbac/apdos-rbac.yaml

sed -i 's/namespace: nginx/namespace: nginx1/' nginx1/rbac/rbac.yaml
sed -i 's/namespace: nginx/namespace: nginx2/' nginx2/rbac/rbac.yaml
sed -i '1, 126d' nginx1/rbac/rbac.yaml
sed -i '1, 126d' nginx2/rbac/rbac.yaml
sed -i '4s/name: nginx-ingress/name: nginx-ingress-nginx1/' nginx1/rbac/rbac.yaml
sed -i '4s/name: nginx-ingress/name: nginx-ingress-nginx2/' nginx2/rbac/rbac.yaml

sed -i 's/namespace: nginx/namespace: nginx1/' nginx1/resources/default-server-secret.yaml
sed -i 's/namespace: nginx/namespace: nginx2/' nginx2/resources/default-server-secret.yaml
sed -i 's/namespace: nginx/namespace: nginx1/' nginx1/resources/nginx-config.yaml
sed -i 's/namespace: nginx/namespace: nginx2/' nginx2/resources/nginx-config.yaml

sed -i 's/namespace: nginx/namespace: nginx1/' nginx1/nginx-plus/nginx-infra.yaml
sed -i 's/namespace: nginx/namespace: nginx2/' nginx2/nginx-plus/nginx-infra.yaml
sed -i 's/nginx-infra/nginx-nginx1/' nginx1/nginx-plus/nginx-infra.yaml
sed -i 's/nginx-infra/nginx-nginx2/' nginx2/nginx-plus/nginx-infra.yaml
sed -i 's/nginx-infra/nginx-nginx1/' nginx1/nginx-plus/ingress-class-infra.yaml
sed -i 's/nginx-infra/nginx-nginx2/' nginx2/nginx-plus/ingress-class-infra.yaml


mv nginx1/nginx-plus/nginx-infra.yaml nginx1/nginx-plus/nginx.yaml
mv nginx2/nginx-plus/nginx-infra.yaml nginx2/nginx-plus/nginx.yaml
mv nginx1/nginx-plus/ingress-class-infra.yaml nginx1/nginx-plus/ingress-class.yaml
mv nginx2/nginx-plus/ingress-class-infra.yaml nginx2/nginx-plus/ingress-class.yaml
rm nginx1/nginx-plus/nginx-plus.yaml
rm nginx2/nginx-plus/nginx-plus.yaml
rm -R nginx1/crds
rm -R nginx2/crds
rm nginx1/nginx-plus/ingress-class-plus.yaml
rm nginx2/nginx-plus/ingress-class-plus.yaml
rm nginx1/nginx-plus/svc-plus.yaml
rm nginx2/nginx-plus/svc-plus.yaml
