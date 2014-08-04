#!/bin/sh

cd ${BASE_DIR}

# Gathering dependencies path
N98_PATH=`which n98-magerun.phar`
if [ -z "$N98_PATH" ]; then
    wget https://raw.github.com/netz98/n98-magerun/master/n98-magerun.phar
    N98_PATH="${BASE_DIR}/n98-magerun.phar"
fi

COMPOSER_PATH=`which composer`
if [ -z "$COMPOSER_PATH" ]; then
    curl -sS https://getcomposer.org/installer | php
    COMPOSER_PATH="${BASE_DIR}/composer.phar"
fi

MODMAN_PATH=`which modman`
if [ -z "$MODMAN_PATH" ]; then
    wget https://raw.githubusercontent.com/colinmollenhour/modman/master/modman -O modman.sh
    chmod a+x ${BASE_DIR}/modman.sh
    MODMAN_PATH="${BASE_DIR}/modman.sh"
fi

PHPUNIT_PATH=`which phpunit`
if [ -f ${BASE_DIR}/vendor/bin/phpunit ]; then
    PHPUNIT_PATH="${BASE_DIR}/vendor/bin/phpunit"
fi

# Installing Magento
INSTALL_NO_DOWNLOAD=""
if [ -f "${BASE_DIR}/${magento_dir}/app/Mage.php" ]; then
    INSTALL_NO_DOWNLOAD="--noDownload"
fi
mysql -uroot --password="${db_pass}" -e "DROP DATABASE IF EXISTS \`${db_name}\`"
rm -f "${BASE_DIR}/${magento_dir}/app/etc/local.xml"
php ${N98_PATH} install ${INSTALL_NO_DOWNLOAD} --installationFolder=${magento_dir} --dbHost=${db_host} --dbUser=${db_user} --dbPass=${db_pass} --dbName=${db_name} --installSampleData=${install_sample_data} --useDefaultConfigParams=yes --magentoVersionByName=${MAGENTO_VERSION} --baseUrl=${base_url}
cd ${magento_dir} && php ${N98_PATH} cache:clean && cd ${BASE_DIR}
cd ${magento_dir} && php ${N98_PATH} cache:disable && cd ${BASE_DIR}

# Installing composer dependencies
${COMPOSER_PATH} install

# Installing & configuring EcomDev_PHPUnit
mysql -uroot --password="${db_pass}" -e "DROP DATABASE IF EXISTS \`${db_test_name}\`"
mysql -uroot --password="${db_pass}" -e "CREATE DATABASE \`${db_test_name}\`"
rm -f "${BASE_DIR}/${magento_dir}/app/etc/local.xml.phpunit"
cd ${magento_dir}/shell && php ecomdev-phpunit.php --action install && cd ${BASE_DIR}
cd ${magento_dir}/shell && php ecomdev-phpunit.php --action change-status && cd ${BASE_DIR}
cd ${magento_dir}/shell && php ecomdev-phpunit.php --action magento-config --db-name ${db_test_name} --base-url ${base_url} && cd ${BASE_DIR}
cd ${magento_dir} && ${PHPUNIT_PATH} --filter EcomDev_PHPUnit
cd ${BASE_DIR}

# Modman module linkng if needed
if [ -f ${BASE_DIR}/modman ]; then
    rm -Rf "${BASE_DIR}/.modman"
    ${MODMAN_PATH} init ${magento_dir}
    ${MODMAN_PATH} link ${BASE_DIR}
fi
