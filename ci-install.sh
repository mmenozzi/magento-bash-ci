#!/bin/sh

cd ${BASE_DIR}

# Gathering dependencies path
PHP_PATH=`which php`

N98_PATH=`which n98-magerun.phar`
if [ -z "$N98_PATH" ]; then
    wget http://files.magerun.net/n98-magerun-latest.phar -O n98-magerun.phar
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

COMPOSER_COMMAND_INTEGRATOR_PATH="";
if [ -f ${BASE_DIR}/vendor/bin/composerCommandIntegrator.php ]; then
    COMPOSER_COMMAND_INTEGRATOR_PATH="${BASE_DIR}/vendor/bin/composerCommandIntegrator.php";
fi

# Installing Magento
mysql -h${db_host} -u${db_user} --password="${db_pass}" -e "DROP DATABASE IF EXISTS \`${db_name}\`"
rm -f "${BASE_DIR}/${magento_dir}/app/etc/local.xml"
if [ -f "${BASE_DIR}/${magento_dir}/app/Mage.php" ]; then
    # Installing composer dependencies
    ${COMPOSER_PATH} install
    # Sometimes it's needed to run composer-command-integrator to successfully deploy extensions
    if [ ! -z "$COMPOSER_COMMAND_INTEGRATOR_PATH" ]; then
        php ${COMPOSER_COMMAND_INTEGRATOR_PATH} magento-module-deploy
    fi
    php ${N98_PATH} install --noDownload --installationFolder=${magento_dir} --dbHost=${db_host} --dbUser=${db_user} --dbPass=${db_pass} --dbName=${db_name} --installSampleData=${install_sample_data} --useDefaultConfigParams=yes --magentoVersionByName=${MAGENTO_VERSION} --baseUrl=${base_url}
else
    php ${N98_PATH} install --installationFolder=${magento_dir} --dbHost=${db_host} --dbUser=${db_user} --dbPass=${db_pass} --dbName=${db_name} --installSampleData=${install_sample_data} --useDefaultConfigParams=yes --magentoVersionByName=${MAGENTO_VERSION} --baseUrl=${base_url}
    ${COMPOSER_PATH} install
    # Sometimes it's needed to run composer-command-integrator to successfully deploy extensions
    if [ ! -z "$COMPOSER_COMMAND_INTEGRATOR_PATH" ]; then
        php ${COMPOSER_COMMAND_INTEGRATOR_PATH} magento-module-deploy
    fi
fi
cd ${magento_dir} && php ${N98_PATH} cache:clean && cd ${BASE_DIR}
cd ${magento_dir} && php ${N98_PATH} cache:disable && cd ${BASE_DIR}


# Modman module linkng if needed
if [ -f ${BASE_DIR}/modman ]; then
    rm -Rf "${BASE_DIR}/.modman"
    ${MODMAN_PATH} init ${magento_dir}
    ${MODMAN_PATH} link ${BASE_DIR}
fi
