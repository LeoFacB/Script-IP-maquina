#! /bin/bash

install_httpd_php()
{
    systemctl start httpd
    systemctl status httpd
    if [ $? -eq 0 ]; then
        yum remove -y "httpd*"
        userdel apache
        rm -Rf /var/www /etc/httpd /usr/lib/httpd
        install_httpd
    else
        yum install -y httpd
        yum install -y php php-cli
        systemctl start httpd
    fi
}

vhost_creation()
{
    echo -e "<VirtualHost *:80>\n   ServerName www.$HOSTNAME.com\n   DocumentRoot "/var/www/html/$HOSTNAME.com"\n</VirtualHost>" >> /etc/httpd/conf.d/"$HOSTNAME".com.conf
}

create_dir()
{
    mkdir /var/www/html/"$HOSTNAME".com
    chown -R apache:apache /var/www/html/"$HOSTNAME".com
    mkdir /etc/content
    cp /etc/content/. /var/www/html/"$HOSTNAME".com
}

firewalld_config()
{
    firewall-cmd --permanent --zone=public --add-port=80/tcp
    firewall-cmd --reload
    sed -i "s/$HOSTNAME/www."$HOSTNAME".com/g" /etc/hosts
    systemctl restart httpd
}

install_httpd_php
create_dir
vhost_creation
firewalld_config