#!/bin/sh

cd ${BASE_DIR}/${magento_dir}

PHPUNIT_PATH=`which phpunit`
if [ -f ${BASE_DIR}/vendor/bin/phpunit ]; then
    PHPUNIT_PATH="${BASE_DIR}/vendor/bin/phpunit"
fi

if [ -z "${phpunit_filter}" ]; then
    ${PHPUNIT_PATH}
else
    ${PHPUNIT_PATH} --filter ${phpunit_filter}
fi
