#!/bin/sh

export db_host="localhost"
export db_user="root"
export db_pass="p4ssw0rd"
export db_name="mage_bash_ci"
export base_url="http://magento_bash_ci.mage.dev/"
export db_test_name="mage_bash_ci_test"
export install_sample_data="yes" # 'yes' or 'no'

export magento_dir="magento" # Magento directory name without heading or trailing slashes
export phpunit_filter="" # [OPTIONAL] Filter (--filter) for phpunit command

export MAGENTO_VERSION="magento-ce-1.8.1.0" # Which Magento version to install (see n98-magerun install command)

export BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # Do not edit this line
export CI_LIB_DIR="$( dirname "${BASE_DIR}" )" # Absolute path of the directory where are located CI scripts

sh ${CI_LIB_DIR}/ci-install.sh
sh ${CI_LIB_DIR}/ci-test.sh
