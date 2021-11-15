#!/bin/sh

cd ${BASE_DIR}

PHPUNIT_PATH=`which phpunit`
if [ -f ${BASE_DIR}/vendor/bin/phpunit ]; then
    PHPUNIT_PATH="${BASE_DIR}/vendor/bin/phpunit"
fi

# Installing & configuring EcomDev_PHPUnit
if [ ! -z ${db_port} ]; then
  db_port="-P${db_port}"
fi
mysql -h${db_host} ${db_port} -u${db_user} --password="${db_pass}" -e "DROP DATABASE IF EXISTS \`${db_test_name}\`"
mysql -h${db_host} ${db_port} -u${db_user} --password="${db_pass}" -e "CREATE DATABASE \`${db_test_name}\`"
rm -f "${BASE_DIR}/${magento_dir}/app/etc/local.xml.phpunit"
cd ${magento_dir}/shell && php ecomdev-phpunit.php --action install && cd ${BASE_DIR}
cd ${magento_dir}/shell && php ecomdev-phpunit.php --action change-status && cd ${BASE_DIR}
cd ${magento_dir}/shell && php ecomdev-phpunit.php --action magento-config --db-name ${db_test_name} --base-url ${base_url} && cd ${BASE_DIR}

if [ -z "${PHPUNIT_CONFIG_PATH}" ]; then
    PHPUNIT_CONFIG_PATH="${BASE_DIR}/${magento_dir}/phpunit.xml.dist"
fi

TEST_WD="$( dirname "${PHPUNIT_CONFIG_PATH}" )"
cd ${TEST_WD}
${PHPUNIT_PATH} --filter EcomDev_PHPUnit
if [ -z "${MBC_PHPUNIT_ARGS}" ]; then
    ${PHPUNIT_PATH}
else
    ${PHPUNIT_PATH} ${MBC_PHPUNIT_ARGS}
fi
