#! /bin/bash

clean_files(){
    if [ "$ (find /etc/httpd/conf.d -name "$HOSTNAME".com.conf)" -eq 0 ]; then
        rm -f /etc/httpd/conf.d/"$HOSTNAME".com.conf
    fi
    systemctl status httpd
    

}