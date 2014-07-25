#!/bin/sh

cd ${BASE_DIR} && pwd

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

rm -Rf "${BASE_DIR}/${magento_dir}"
rm -Rf "${BASE_DIR}/vendor"
rm -Rf "${BASE_DIR}/.modman"
mysql -uroot --password="${db_pass}" -e "DROP DATABASE IF EXISTS \`${db_name}\`"
mysql -uroot --password="${db_pass}" -e "DROP DATABASE IF EXISTS \`${db_test_name}\`"

php ${N98_PATH} install --installationFolder=${magento_dir} --dbHost=${db_host} --dbUser=${db_user} --dbPass=${db_pass} --dbName=${db_name} --installSampleData=${install_sample_data} --useDefaultConfigParams=yes --magentoVersionByName=${MAGENTO_VERSION} --baseUrl=${base_url}
cd ${magento_dir} && php ${N98_PATH} cache:clean && cd ${BASE_DIR}
cd ${magento_dir} && php ${N98_PATH} cache:disable && cd ${BASE_DIR}

${COMPOSER_PATH} install

mysql -uroot --password="${db_pass}" -e "CREATE DATABASE \`${db_test_name}\`"
cd ${magento_dir}/shell && php ecomdev-phpunit.php --action install && cd ${BASE_DIR}
cd ${magento_dir}/shell && php ecomdev-phpunit.php --action change-status && cd ${BASE_DIR}
cd ${magento_dir}/shell && php ecomdev-phpunit.php --action magento-config --db-name ${db_test_name} --base-url ${base_url} && cd ${BASE_DIR}
cd ${magento_dir} && ${BASE_DIR}/vendor/bin/phpunit --filter EcomDev_PHPUnit

cd ${BASE_DIR}
${MODMAN_PATH} init ${magento_dir}
${MODMAN_PATH} link ${BASE_DIR}
