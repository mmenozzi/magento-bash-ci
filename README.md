Magento Bash CI Library
=======================

Simple bash library to automate Continuous Integration process during Magento development.

Usage
-----

* Clone this repository using git-submodule
* Copy provided ci.sh.sample script in your root directory
* Set db settings and other params (see also the following charapter)
* Run CI with `sh ci.sh`

Set `BASE_DIR` and `CI_LIB_DIR`
-------------------------------

It's recommended to use the `SCRIPT_DIR` variable to set `BASE_DIR` and `CI_LIB_DIR`. `SCRIPT_DIR` value is always the absolute path of the directory where your `ci.sh` script is located regardless your current working directory. For example, if you put your script in a `bin` subdirectory:

```
./
├── bin/
│   └── ci.sh
├── composer.json
├── magento/
└── magento-bash-ci/
```

You should set `BASE_DIR` and `CI_LIB_DIR` as follows:
```
BASE_DIR="$( dirname ${SCRIPT_DIR} )"
CI_LIB_DIR="${BASE_DIR}/magento-bash-ci"
```
