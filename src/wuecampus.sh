#!/bin/bash
#Wuecampus

get_metavars_wuecampus()
{
        wuecampus_loginurl=$(echo "$config_meta" | grep -o '^loginurl:.*' | sed -e 's/^loginurl:\s*//' -e 's/\s*$//')
        wuecampus_logouturl=$(echo "$config_meta" | grep -o '^logouturl:.*' | sed -e 's/^logouturl:\s*//' -e 's/\s*$//')
        wuecampus_loginid=$(echo "$config_meta" | grep -o '^loginid:.*' | sed -e 's/^loginid:\s*//' -e 's/\s*$//')
        wuecampus_userid=$(echo "$config_meta" | grep -o '^userid:.*' | sed -e 's/^userid:\s*//' -e 's/\s*$//')
        wuecampus_pwid=$(echo "$config_meta" | grep -o '^pwid:.*' | sed -e 's/^pwid:\s*//' -e 's/\s*$//')        
        wuecampus_cookie=$(echo "$config_meta" | grep -o '^cookie:.*' | sed -e 's/^cookie:\s*//' -e 's/\s*$//' | sed -e 's/"//g')
        wuecampus_pw=$(echo "$config_meta" | grep -o '^pw:.*' | sed -e 's/^pw:\s*//')        
        wuecampus_username=$(echo "$config_meta" | grep -o '^username:.*' | sed -e 's/^username:\s*//' -e 's/\s*$//' | sed -e 's/"//g')
}

wuecampus_downloader()
{
        read_config wuecampus
        get_metavars_wuecampus
        downloadlist=$(echo "$downloads" | awk 'BEGIN { FS="\n";RS="- ";OFS=";"; } NR>=2 { print $1, $2, $3, $4 }')
        login_wuecampus
        while read -r line; do
                wuecampus_id=$(echo $line | grep -o 'id: [^;]*'| sed -e 's/"//g' | sed -e 's/^id:\s//' -e 's/\s*$//')
                wuecampus_section=$(echo $line | grep -o 'section: [^;]*'| sed -e 's/"//g' | sed -e 's/^section:\s//' -e 's/\s*$//')
                wuecampus_dir=$(echo $line | grep -o 'dir: [^;]*'| sed -e 's/"//g' | sed -e 's/^dir:\s//' -e 's/\s*$//')
                get_filelist_wuecampus
                download_files_wuecampus
        done <<< "$downloadlist"
        logout_wuecampus
}

get_filelist_wuecampus()
{
        files=$(curl --silent -L -b ${wuecampus_cookie} "https://wuecampus2.uni-wuerzburg.de/moodle/course/view.php?id=${wuecampus_id}&section=${wuecampus_section}" | grep -o -b '.*resource.*' | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | grep -o -b '.*pdf.*' | grep -o '&#039;.*&amp' | sed 's/^&#039\;//;s/&amp$//' | xargs -I {} curl --silent -L -b ${wuecampus_cookie} {} | grep -o -b '.*class="resourceworkaround.*"' | grep -o -b 'href=".*.pdf"' | grep -o '".*"' | sed 's/"//g')
}

download_files_wuecampus()
{
        startdir=$(pwd)
        cd ${wuecampus_dir/#~/$HOME}
        if [ "$#" -gt 0 ];then
                grep $1 <<< "$files" | xargs -I {} wget -N --load-cookies ${wuecampus_cookie} {}
        else
                xargs -I {} wget -N --load-cookies ${wuecampus_cookie} {} <<< "$files"
        fi
        cd $startdir
}

login_wuecampus()
{
        wuecampus_logintoken=$(curl --silent -L -c ${wuecampus_cookie} -b ${wuecampus_cookie} "https://wuecampus2.uni-wuerzburg.de/" | grep -o 'name="logintoken".*value=".*"'  | grep -o 'value=".*"' | sed -e 's/value=//' -e 's/"//g')
        wuecampus_sessionkey=$(curl --silent -L -c ${wuecampus_cookie} -b ${wuecampus_cookie} -d "anchor=&logintoken=${wuecampus_logintoken}&${wuecampus_userid}=${wuecampus_username}&${wuecampus_pwid}=${wuecampus_pw}" ${wuecampus_loginurl} | grep -o '"sesskey":"\w*"' | sed -e 's/"//g' -e 's/sesskey://')
}

logout_wuecampus()
{
        curl --silent -L -b ${wuecampus_cookie} -d "sesskey=${wuecampus_sessionkey}" ${wuecampus_logouturl} >/dev/null
        rm ${wuecampus_cookie}
}

