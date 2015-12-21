#!/bin/sh

cd ${BASE_DIR}

PHPUNIT_PATH=`which phpunit`
if [ -f ${BASE_DIR}/vendor/bin/phpunit ]; then
    PHPUNIT_PATH="${BASE_DIR}/vendor/bin/phpunit"
fi

# Installing & configuring EcomDev_PHPUnit
mysql -uroot --password="${db_pass}" -e "DROP DATABASE IF EXISTS \`${db_test_name}\`"
mysql -uroot --password="${db_pass}" -e "CREATE DATABASE \`${db_test_name}\`"
rm -f "${BASE_DIR}/${magento_dir}/app/etc/local.xml.phpunit"
cd ${magento_dir}/shell && php ecomdev-phpunit.php --action install && cd ${BASE_DIR}
cd ${magento_dir}/shell && php ecomdev-phpunit.php --action change-status && cd ${BASE_DIR}
cd ${magento_dir}/shell && php ecomdev-phpunit.php --action magento-config --db-name ${db_test_name} --base-url ${base_url} && cd ${BASE_DIR}
cd ${magento_dir} && ${PHPUNIT_PATH} --filter EcomDev_PHPUnit
cd ${BASE_DIR}/${magento_dir}

if [ -z "${MBC_PHPUNIT_ARGS}" ]; then
    ${PHPUNIT_PATH}
else
    ${PHPUNIT_PATH} ${MBC_PHPUNIT_ARGS}
fi
