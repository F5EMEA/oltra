# Installing and using NGINX Plus with App Protect on a docker container
We will first install the NGINX Plus instance with App Protect on an Docker containter and run some basic tests.

## 1.1 NGINX Plus Installation

1. Connect with WebSSH to Docker host.


2. Change directory to `/home/ubuntu/lab-files`.
```
cd /home/ubuntu/lab-files 
```

3. Verify that the contents of the directory. You should see the NGINX SSL cert/keys and the Dockerfile.
```
ls -la 
```

4. Review the contents of the Dockerfile.
```
cat Dockerfile 
```
The results should be the following:

```dockerfile 
   #For CentOS 7
   FROM centos:7.4.1708

   # Download certificate and key from the customer portal (https://cs.nginx.com)
   # and copy to the build context
   COPY nginx-repo.crt nginx-repo.key /etc/ssl/nginx/

   # Install prerequisite packages
   RUN yum -y install wget ca-certificates epel-release

   # Add NGINX Plus repo to yum
   RUN wget -P /etc/yum.repos.d https://cs.nginx.com/static/files/nginx-plus-7.repo
   RUN wget -P /etc/yum.repos.d https://cs.nginx.com/static/files/app-protect-security-updates-7.repo

   # Install NGINX App Protect
   RUN yum -y install app-protect app-protect-attack-signatures\
      && yum clean all \
      && rm -rf /var/cache/yum \
      && rm -rf /etc/ssl/nginx

   # Forward request logs to Docker log collector:
   RUN ln -sf /dev/stdout /var/log/nginx/access.log \
      && ln -sf /dev/stderr /var/log/nginx/error.log

   # Copy configuration files:
   COPY nginx.conf custom_log_format.json /etc/nginx/
   COPY entrypoint.sh  /root/

   CMD ["sh", "/root/entrypoint.sh"]
```

3. Build the dockerfile
```
docker build --tag skenderidis/app-protect:v1 .
```

4. Run the docker created
```
docker run -dit --rm --name app-protect -p 80:80 skenderidis/app-protect:v1
```

5. Test the WAF.
```
curl x.x.x.x.xx.x.x.x
```

6. Make a change to the WAF Policy (from `blocking` to `transparent`).
The following steps have have to be followed:
- Step 1. Use `vi` or `nano` to open the `waf-policy.json` and change enforcement to `transparent`. 

- Step 2. Rebuild the docker image with the following command `docker build --tag skenderidis/app-protect:v2` .


