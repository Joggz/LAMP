#!/bin/bash

# Function to display error messages and exit
error_exit() {
    echo "$1" >&2
    exit 1
}
echo "======update, apache, ondrej, php and dependies ======="
sudo apt update || error_exit "Failed to update package lists"
sudo apt install -y apache2 || error_exit "Failed to install Apache"
sudo add-apt-repository -y ppa:ondrej/php
sudo apt update || error_exit "Failed to update package lists"
sudo apt install -y  php8.2  || error_exit "Failed to php"
sudo apt install -y  php8.2-curl php8.2-dom php8.2-mbstring php8.2-xml php8.2-mysql zip unzip

echo "=======Install COmposer======"
cd /usr/local/bin
sudo curl -sS https://getcomposer.org/installer | sudo php -q
composer --version
sudo mv composer.phar composer
#sudo curl -sS  https://getcomposer.org/installer | php -- --version=2.7.2
#sudo mv composer.phar /usr/local/bin/composer
echo "=======Composer Done======"

echo "==========clone laravel project and install dependecies ========"
cd /var/www/  && sudo  git clone https://github.com/laravel/laravel.git
sudo chown -R $USER:$USER /var/www/laravel
cd laravel/  &&   composer install

sudo cp .env.example .env
sudo php artisan key:generate

#had some errors with storage , dont think i should  uncomment this
#sudo chown -R www-data storage
#sudo chown -R www-data bootstrap/cache

echo "==========clone laravel project and install dependecies Done========"
echo "========configure apache virtualhost======="
cd  /etc/apache2/sites-available/
sudo touch  larav.conf

#virtualcontent
echo "<VirtualHost *:80>" | sudo tee /etc/apache2/sites-available/larav.conf > /dev/null
echo "    ServerAdmin larav@laravele.com" | sudo tee -a /etc/apache2/sites-available/larav.conf > /dev/null
echo "    ServerName 192.168.56.5" | sudo tee -a /etc/apache2/sites-available/larav.conf > /dev/null
echo "    ServerAlias www.laravele.com" | sudo tee -a /etc/apache2/sites-available/larav.conf > /dev/null
echo "    DocumentRoot /var/www/laravel/public" | sudo tee -a /etc/apache2/sites-available/larav.conf > /dev/null
echo "    ErrorLog ${APACHE_LOG_DIR}/error.log" | sudo tee -a /etc/apache2/sites-available/larav.conf > /dev/null
echo "    CustomLog ${APACHE_LOG_DIR}/access.log combined" | sudo tee -a /etc/apache2/sites-available/larav.conf > /dev/null
echo "</VirtualHost>" | sudo tee -a /etc/apache2/sites-available/larav.conf > /dev/null

sudo a2ensite larav.conf
sudo a2dissite 000-default.conf
sudo systemctl restart apache2
echo "========configure apache virtualhost Done======="

#sudo systemctl restart apache2 && sudo systemctl reload apache2
