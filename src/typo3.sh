#!/bin/bash
#Typo3

get_metavars_typo3()
{
        typo3_baseurl=$(echo "$config_meta" | grep -o '^typo3_baseurl:.*' | sed -e 's/^typo3_baseurl:\s*//' -e 's/\s*$//')
        typo3_faid=$(echo "$config_meta" | grep -o '^typo3_faid:.*' | sed -e 's/^typo3_faid:\s*//' -e 's/\s*$//')
}

typo3_downloader()
{
        read_config typo3
        get_metavars_typo3
        downloadlist=$(echo "$downloads" | awk 'BEGIN { FS="\n";RS="- ";OFS=";"; } NR>=2 { print $1, $2, $3, $4 }')
        while read -r line; do
                typo3_id=$(echo $line | grep -o 'id: [^;]*'| sed -e 's/"//g' | sed -e 's/^id:\s*//' -e 's/\s*$//')
                typo3_dir=$(echo $line | grep -o 'dir: [^;]*'| sed -e 's/"//g' | sed -e 's/^dir:\s*//' -e 's/\s*$//')
                typo3_download_option=$(echo $line | grep -o 'download_option: [^;]*' |  sed -e 's/^download_option:\s*//' -e 's/\s*$//' | sed -e 's/"//g')
                get_filelist_typo3
                download_files_typo3 "$typo3_download_option"
        done <<< "$downloadlist"
}

get_filelist_typo3()
{
        files=$(curl --silent ${typo3_baseurl}/index.php?id=${typo3_id} | grep -o -b ".*${typo3_faid}.*" | awk '{for(i=1;i<=NF;i++){ if($i ~ /href=.*/){print $i} } }' | grep -o '".*"' | sed 's/"//g'| grep -o  '/fileadmin.*')
}

download_files_typo3()
{
        startdir=$(pwd)
        cd ${typo3_dir/#~/$HOME}
        if [ "$#" -gt 0 ];then
                grep $1 <<< "$files" | xargs -I {} wget -N ${typo3_baseurl}{}
        else
                xargs -I {} wget -N ${typo3_baseurl}{} <<< "$files"
        fi
        cd $startdir
}

