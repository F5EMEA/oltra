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

sed -i 's/namespace: nginx/namespace: nginx1/' nginx1/nginx-plus/nginx-plus.yaml
sed -i 's/namespace: nginx/namespace: nginx2/' nginx2/nginx-plus/nginx-plus.yaml
sed -i 's/name: nginx-plus/name: nginx-nginx1/' nginx1/nginx-plus/nginx-plus.yaml
sed -i 's/name: nginx-plus/name: nginx-nginx2/' nginx2/nginx-plus/nginx-plus.yaml
sed -i 's/app: nginx-plus/app: nginx-nginx1/' nginx1/nginx-plus/nginx-plus.yaml
sed -i 's/app: nginx-plus/app: nginx-nginx2/' nginx2/nginx-plus/nginx-plus.yaml
sed -i 's/app: nginx-plus/app: nginx-nginx1/' nginx1/nginx-plus/nginx-plus.yaml
sed -i 's/ingress-class=nginx-plus/ingress-class=nginx1/' nginx1/nginx-plus/nginx-plus.yaml
sed -i 's/ingress-class=nginx-plus/ingress-class=nginx2/' nginx2/nginx-plus/nginx-plus.yaml

sed -i '4s/name: nginx/name: nginx1/' nginx1/nginx-plus/ingress-class-plus.yaml
sed -i '4s/name: nginx/name: nginx2/' nginx2/nginx-plus/ingress-class-plus.yaml

sed -i 's/nginx-plus/nginx-nginx1/' nginx1/nginx-plus/ingress-class-plus.yaml
sed -i 's/nginx-plus/nginx-nginx2/' nginx2/nginx-plus/ingress-class-plus.yaml


sed -i '16, 16d' nginx1/nginx-plus/svc-plus.yaml
sed -i '11, 11d' nginx1/nginx-plus/svc-plus.yaml
sed -i '16, 16d' nginx2/nginx-plus/svc-plus.yaml
sed -i '11, 11d' nginx2/nginx-plus/svc-plus.yaml
sed -i 's/nginx-plus/nginx-nginx1/' nginx1/nginx-plus/svc-plus.yaml
sed -i 's/nginx-plus/nginx-nginx2/' nginx2/nginx-plus/svc-plus.yaml
sed -i 's/namespace: nginx/namespace: nginx1/' nginx1/nginx-plus/svc-plus.yaml
sed -i 's/namespace: nginx/namespace: nginx2/' nginx2/nginx-plus/svc-plus.yaml


rm -R nginx1/crds
rm -R nginx2/crds
rm -R nginx1/publish
rm -R nginx2/publish
