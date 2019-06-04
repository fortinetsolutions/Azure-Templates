
#! /bin/bash
azureuser=$1
echo "=====================================installing the test website in workload VM========================================"

cd /home/$azureuser

git clone https://github.com/brannondorsey/SlowLoris
cd SlowLoris
sudo apt-get update -y
sleep 60
sudo apt install docker.io -y
sudo docker pull httpd
sleep 40
sudo docker run -d --name apache -p 8888:80 -v "$PWD/www":/usr/local/apache2/htdocs/ httpd:2.4