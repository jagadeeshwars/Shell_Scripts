#!/bin/bash

function print_color(){
    NC='\033[0m'

    case $1 in 
      "green") color='\033[0;32m' ;;
      "red") color='\033[0;31m' ;;
      "*") color='\033[0m' ;;
    esac

    echo -e "${color} $2 ${NC}"
}

function package_install() {
    sudo yum install -y $1
}
function check_service_status() {
    is_service_active=$(sudo systemctl is-active $1)

    if [ "$is_service_active" == "active" ]
    then
        print_color "green" "$1 is active"
    else   
        print_color "red" "$1 is not active"
        exit 1
    fi
}

function check_port_status() {
    is_port_active=$(sudo firewall-cmd --list-ports --zone=public)
    if [[ $is_port_active == *$1* ]]
    then
        print_color "green" "$1 is active"
    else
        print_color "red" "$1 is not active"
        exit 1
    fi
}

function check_webpage() {
    if [[ $1 == *$2* ]]
    then 
        echo "Item $2 present in the the webpage"
    else
        echo "Item $2 is not present in the webpage"
    fi
}
print_color "green" "Installing and Configuring Database..."

#Updating Packages
#print_color "green" "Updating Repository..."
#sudo yum update -y

#Install and configure FirewallD
print_color "green" "Installing FirewallD..."
package_install firewalld

print_color "green" "Starting FirewallD..."
sudo systemctl start firewalld
sudo systemctl enable firewalld
check_service_status firewalld

#Install and configure Database
print_color "green" "Installing MariaDB..."
package_install mariadb-server

print_color "green" "Starting MariaDB..."
sudo systemctl start mariadb
sudo systemctl enable mariadb
check_service_status mariadb

print_color "green" "Enabling Port in Firewall..."
sudo firewall-cmd --permanent --zone=public --add-port=3306/tcp
sudo firewall-cmd --reload
check_port_status 3306

#Create Dtabase and Grant User Privileges
sudo cat > create-database.sql <<-EOF
CREATE DATABASE ecomdb;
CREATE USER 'ecomuser'@'localhost' IDENTIFIED BY 'ecompassword';
GRANT ALL PRIVILEGES ON *.* TO 'ecomuser'@'localhost';
FLUSH PRIVILEGES;

EOF

sudo mysql < create-database.sql

#Load Tables into Database
sudo cat > db-load-script.sql <<-EOF
USE ecomdb;
CREATE TABLE products (id mediumint(8) unsigned NOT NULL auto_increment,Name varchar(255) default NULL,Price varchar(255) default NULL, ImageUrl varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;

INSERT INTO products (Name,Price,ImageUrl) VALUES ("Laptop","100","c-1.png"),("Drone","200","c-2.png"),("VR","300","c-3.png"),("Tablet","50","c-5.png"),("Watch","90","c-6.png"),("Phone Covers","20","c-7.png"),("Phone","80","c-8.png"),("Laptop","150","c-4.png");

EOF

sudo mysql < db-load-script.sql

#Install Apache Webserver and PHP
print_color "green" "Installing Apache and PHP..."
for i in httpd php php-mysqlnd
do 
    package_install "$i"
done

#Configure Firewall port
print_color "green" "Enabling port in Firewall..."
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
sudo firewall-cmd --reload
check_port_status 80

#Editing httpd config file
sudo sed -i 's/index.html/index.php/g' /etc/httpd/conf/httpd.conf

#Starting httpd service
print_color "green" "Starting service..."
sudo systemctl start httpd
sudo systemctl enable httpd
check_service_status httpd

#Install Git
print_color "green" "Installing GIT..."
sudo yum install -y git
sudo git clone https://github.com/kodekloudhub/learning-app-ecommerce.git /var/www/html/
sudo sed -i 's#// \(.*mysqli_connect.*\)#\1#' /var/www/html/index.php
sudo sed -i 's#// \(\$link = mysqli_connect(.*172\.20\.1\.101.*\)#\1#; s#^\(\s*\)\(\$link = mysqli_connect(\$dbHost, \$dbUser, \$dbPassword, \$dbName);\)#\1// \2#' /var/www/html/index.php
print_color "green" "Checking_Webpage..."

web_page=$(curl http://localhost)

for item in Laptop Drone VR Watch Phone
do
    check_webpage "$web_page" $item
done


