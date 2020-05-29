#!/bin/bash
yum install -y epel-release $> /dev/null
yum install nginx –y &> /dev/null
systemctl disable httpd &> /dev/null
systemctl start nginx &> /dev/null
systemctl enable nginx &> /dev/null
firewall-cmd --zone=public --permanent --add-service=http &> /dev/null
firewall-cmd --zone=public --permanent --add-service=https &> /dev/null
firewall-cmd --reload &> /dev/null


PS3='Please enter your choice: '
options=("Reverse Proxy" "Reverse Proxy & Load balancer"  "Quit")
select opt in "${options[@]}"
do
case $opt in

"Reverse Proxy")

echo "Enter site  IP"
read site_ip

echo "

user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

server {

  listen 80;
  listen [::]:80;


location / {

proxy_pass http://$site_ip:80 ;

}
}
}
" > /etc/nginx/nginx.conf

   ;;    

"Reverse Proxy & Load balancer")
         
echo "
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;
upstream yahia   {
" > /etc/nginx/nginx.conf

echo "Enter number of Nodes"
read number
for i in $(seq 1 $number)
do

echo "Enter $i  Node IP"
read ip

echo "
	server $ip;
" >> /etc/nginx/nginx.conf

done 

echo "
}
server  {
listen 80;
listen [::]:80;
location / {

proxy_pass http://yahia;

}

}
}

" >> /etc/nginx/nginx.conf
            
;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

nginx -t 
nginx -s reload 


