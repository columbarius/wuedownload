#/bin/bash

config=$HOME/.config/wuedownload/config.yml

read_config()
{
        config_meta=$(sed -n "/^$1\\S$/,/^\\(\\|\\S.*\\)$/{/^\\(\\|\\S.*\\)$/!p}" ${config} | sed -s 's/^        //' | sed -n '/^\S/{/downloads\S/!p}')
        downloads=$(sed -n "/^$1\\S$/,/^\\(\\|\\S.*\\)$/{/^\\(\\|\\S.*\\)$/!p}" ${config} | sed -e 's/^        //' | sed -n '/^downloads\S$/,/^\(\|\S.*\)$/{/^\(\|\S.*\)$/!p}' | sed -e 's/^        //')
}

typo3_downloader

wuecampus_downloader

exit

