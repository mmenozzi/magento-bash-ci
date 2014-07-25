#!/bin/sh

cd ${BASE_DIR}/${magento_dir} && pwd
if [ -z "${phpunit_filter}" ]; then
    ${BASE_DIR}/vendor/bin/phpunit
else
    ${BASE_DIR}/vendor/bin/phpunit --filter ${phpunit_filter}
fi
