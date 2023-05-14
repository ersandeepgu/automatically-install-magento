# @category   Magento2.XX
# @package    InstallMagentoScript
# @author Sandeep Gupta
# @email ersandeepgu@gmail.com
# @license    http://opensource.org/licenses/osl-3.0.php  Open Software License (OSL 3.0)


#!/bin/bash

# Ask the user for the Magento version and edition


read -p "Please specify the Magento version you want to install (e.g. 2.4.2)  " version
read -p "Would you like to install the Community or Enterprise edition? Enter 'C' or 'E'  " edition
# Set up variables for your installation
if [ "$edition" == "E" ]; then
    magentoRepo="https://repo.magento.com"
    magentoPackage="magento/project-enterprise-edition"
else
    magentoRepo="https://repo.magento.com"
    magentoPackage="magento/project-community-edition"
fi

read -p "Write the Name of Magento folder or Domain example magentotesting, example.com  " domain 
read -p "Write the name of database example magentoStg, magentoPro  "  dbname 
read -p "Enter your database Host name example magentoStg, magentoPro  "  dbhost 
read -p "Enter your database User name example magentoStg, magentoPro  "  dbuser 
read -p "Enter your database Password name example magentoStg, magentoPro  " dbpass 
# domain="example.com"
# domain="example.com"
# dbname="magento"
# dbuser="magento"
# dbpass="yourpassword"
cd /var/www/html/

# Install Magento using composer
composer create-project --repository-url=$magentoRepo $magentoPackage /var/www/html/$domain $version

# Set the correct permissions for your Magento installation
# sudo chown -R www-data:www-data /var/www/html/$domain
sudo chmod -R 755 /var/www/html/$domain

# Create a new MySQL database for your installation
sudo mysql -e "CREATE DATABASE $dbname;"
sudo mysql -e "CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$dbpass';"
sudo mysql -e "GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@'$dbhost';"

# Run the Magento installation wizard
sudo php /var/www/html/$domain/bin/magento setup:install \
--base-url=http://localhost/$domain/pub/ \
--db-host=$dbhost \
--db-name=$dbname \
--db-user=$dbuser \
--db-password=$dbpass \
--admin-firstname=Admin \
--admin-lastname=User \
--admin-email=sandeep@example.com \
--admin-user=admin \
--admin-password=admin@123 \
--timezone=America/Los_Angeles \
--currency=USD \
--language=en_US \
--use-rewrites=1 \
--use-secure=0 \
--use-secure-admin=0 \
--backend-frontname=admin \
--search-engine=elasticsearch7 \
--elasticsearch-host=elasticsearch \
--elasticsearch-port=9200

# Clear the cache and generate static content
sudo php /var/www/html/$domain/bin/magento setup:upgrade
sudo php /var/www/html/$domain/bin/magento cache:clean
sudo php /var/www/html/$domain/bin/magento cache:flush
sudo php /var/www/html/$domain/bin/magento setup:static-content:deploy -f

# Print the frontend and backend URLs with admin credentials
echo "Frontend URL: http://localhost/$domain/pub/"
echo "Backend URL: http://localhost/$domain/admin"
echo "Admin Username: admin"
echo "Admin Password: admin@123"
