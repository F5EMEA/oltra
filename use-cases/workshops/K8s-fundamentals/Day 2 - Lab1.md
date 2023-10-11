# Installing and using NGINX Plus with App Protect on a VM
We will first install the NGINX Plus instance with App Protect on an Ubuntu 20.04 Host and run some basic tests.

## 1.1 NGINX Plus Installation

1. Download the NGINX SSL cert/key
```
git clone https://github.com/skenderidis/certs
```
When asked please use `skenderidis` as username and password `xxxx`

2. Create NGINX ssl folder and move the NGINX keys. 
```
mkdir /etc/ssl/nginx/
mv certs/nginx-repo.crt /etc/ssl/nginx/
mv certs/nginx-repo.key /etc/ssl/nginx/
```

ls -la /etc/ssl/nginx/ 
> Note: We have predeployed the NGINX Plus keys on that particular host

2. Install prerequisite packages.
```
sudo apt-get update && sudo apt-get install apt-transport-https lsb-release ca-certificates wget gnupg2
```

3. Download and add the NGINX signing keys.
```
sudo wget https://cs.nginx.com/static/keys/nginx_signing.key && sudo apt-key add nginx_signing.key
sudo wget https://cs.nginx.com/static/keys/app-protect-security-updates.key && sudo apt-key add app-protect-security-updates.key
```

4. Remove any previous NGINX Plus repository and apt configuration files. (Only if you installed the NGINX Plus before)
```
sudo rm /etc/apt/sources.list.d/nginx-plus.list
sudo rm /etc/apt/sources.list.d/*app-protect*.list
sudo rm /etc/apt/apt.conf.d/90pkgs-nginx
```

5. Add NGINX Plus repository.
```
printf "deb https://pkgs.nginx.com/plus/ubuntu `lsb_release -cs` nginx-plus\n" | sudo tee /etc/apt/sources.list.d/nginx-plus.list
```

6. Add NGINX App Protect WAF repositories.
```
printf "deb https://pkgs.nginx.com/app-protect/ubuntu `lsb_release -cs` nginx-plus\n" | sudo tee /etc/apt/sources.list.d/nginx-app-protect.list
printf "deb https://pkgs.nginx.com/app-protect-security-updates/ubuntu `lsb_release -cs` nginx-plus\n" | sudo tee /etc/apt/sources.list.d/app-protect-security-updates.list
```

7. Download the apt configuration to /etc/apt/apt.conf.d.
```
sudo wget -P /etc/apt/apt.conf.d https://cs.nginx.com/static/files/90pkgs-nginx
```

8. Update the repository and install the most recent version of the NGINX App Protect WAF package (which includes NGINX Plus):
```
sudo apt-get update
sudo apt-get install app-protect
```

9. Check the NGINX binary version to ensure that you have NGINX Plus installed correctly.
```
sudo nginx -v
```

10. Start the NGINX service.
```
sudo systemctl start nginx
```


11. Verify that the installation is successfull by accessing the service. 
```
curl localhost
```


## 1.2 Enabling App Protect

1. Review the default configuration of NGINX and App Protect that has been setup during the isntallation. The files to review are:
- /etc/nginx/nginx.conf
- /etc/nginx/conf.d/default.conf

```
cat /etc/nginx/nginx.conf
cat /etc/nginx/conf.d/default.conf
```

Also review the default App Protect configuration that is location on 
```
cat /etc/app_protect/conf/NginxDefaultPolicy.json           <----- Default Policy ----
cat /etc/app_protect/conf/NginxStrictPolicy.json            <----- Strict Policy -----
cat /etc/app_protect/conf/NginxApiSecurityPolicy.json       <----- API Policy --------
cat /etc/app_protect/conf/log_default.json                  <----- Logging Profile ---
```

2. In the main (top-level) context in `/etc/nginx/nginx.conf`, add a load_module directive for app protect that we just installed.
   ```
   load_module modules/ngx_http_app_protect_module.so;
   ```

It should look something like this

   ```

   user  nginx;
   worker_processes  auto;
   worker_rlimit_nofile 1048576;

   error_log  /var/log/nginx/error.log notice;
   pid        /var/run/nginx.pid;

   load_module modules/ngx_http_app_protect_module.so;    <----  Add this --------------

   events {
         worker_connections 1048576;
         #use epoll;
         multi_accept on;
   }
   ...
   ...
   ...
   ```

2. Create the load balancing configuration and enable WAF. 

Create a new file `lb.conf` in the `/etc/nginx/conf.d/` directory and add the following contents

```
nano lb.conf
```

Copy & Paste the following configuration on `lb.conf`
```
    server {
        listen       80;
        #server_name  www.nginx.local;

        location / {
            app_protect_enable off;
            app_protect_policy_file "/etc/app_protect/conf/NginxDefaultPolicy.json";
            app_protect_security_log_enable on; 
            app_protect_security_log "/etc/app_protect/conf/test.json" /home/ubuntu/logs/waf.log;

            proxy_pass    http://10.1.1.7:3000/$request_uri;
        }

    }


```


3. Check the new configuration for syntactic validity and reload NGINX Plus.

```
nginx -t && nginx -s reload

```


4. Access the website through NGINX Plus

```
nginx -t && nginx -s reload

```


5. Launch some attacks and review the logs generated. 

```
xxxxxxxxxx
```



## 1.2 Modifying App Protect Policies
Most of the configuration of a NAP policy is included as part of the template `POLICY_TEMPLATE_NGINX_BASE` and if something is not explcitly mentioned, NAP assumes the tempate's default values.

```
{
    "policy" : {
        "name": "app_protect_default_policy",
        "template": { "name": "POLICY_TEMPLATE_NGINX_BASE" }
    }
}
```

To see the actual configuration you are applying, along with the template's default values, you have to run the Policy Converter tool to extract the full configuration. More info about the Converter tool can be found on https://docs.nginx.com/nginx-app-protect-waf/configuration-guide/configuration/#policy-converter.

Run the following command to extract and save the entire NAP configuraiton for 'app_protect_default_policy'
```
sudo /opt/app_protect/bin/convert-policy -i /etc/app_protect/conf/NginxDefaultPolicy.json -o ~/full-policy.json --full-export
```

Review the policy that was exported.
```
cat ~/full-policy.json
```


1. Protect againt Illegal parameter data types.
To achieve that we need to do 2 things:
- Create a new parameter and set it as integer.
- Change the DataType violation to blocking


2. Protect againt Illegal parameter value lengths.
To achieve that we need to do 2 things:
- Create a new parameter and set the minimum and maximum accepted values.
- Change the DataType violation to blocking


2. Protect againt Illegal parameter static values.
To achieve that we need to do 2 things:
- Create a new parameter and set the minimum and maximum accepted values.
- Change the DataType violation to blocking

