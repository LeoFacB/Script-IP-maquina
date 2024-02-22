#! /bin/bash

clean_files()
{
    if [ "$ systemctl status httpd" -eq 0 ]; then 
        echo "HTTPD encontrado, desisnstalando"
        yum remove -y "httpd*"
        userdel apache
        rm -Rf /var/www /etc/httpd /usr/lib/httpd
        if [ "$ (systemctl stattus httpd)" -eq 1 ]; then
            clean_files
        else
            echo "Arquivo removido com sucesso!"
        fi
    fi
}

install_httpd()
{
    systemctl start httpd
    if [ "$ (systemctl stattus httpd)" -eq 0 ]; then
        echo "HTTPD encontrado, desinstalando"
        yum remove -y "httpd*"
        userdel apache
        rm -Rf /var/www /etc/httpd /usr/lib/httpd
        echo "HTTPD removido com sucesso!"
        install_httpd
    else
        echo "HTTPD nao instalado, iniciando download"
        yum install -y httpd
        systemctl start httpd
        echo "HTTPD instalado com sucesso"
    fi
}

install_php()
{
    echo "Instalando PHP"
    yum install -y php php-cli
}

vhost_creation()
{
    if [ "$ (nano /etc/httpd/conf.d/"$HOSTNAME".com.conf)" -eq 0 ]; then
        echo -e "<VirtualHost *:80>\n   ServerName www.$HOSTNAME.com\n   ServerAlias $HOSTNAME.com\n   DocumentRoot "/var/www/html/$HOSTNAME.com"\n</VirtualHost>" >> /etc/httpd/conf.d/"$HOSTNAME".com.conf
    else
        rm -f /etc/httpd/conf.d/"$HOSTNAME".com
        nano -f /etc/httpd/conf.d/"$HOSTNAME".com
        echo -e "<VirtualHost *:80>\n   ServerName www.$HOSTNAME.com\n   ServerAlias $HOSTNAME.com\n   DocumentRoot "/var/www/html/$HOSTNAME.com"\n</VirtualHost>" >> /etc/httpd/conf.d/"$HOSTNAME".com.conf
    fi
    systemctl restart httpd.service
}

search_cp_dir()
{
    mkdir /var/www/html/"$HOSTNAME".com
    chown -R apache:apache /var/www/html/"$HOSTNAME".com
    vhost_creation
    mkdir /etc/content
    cp /etc/content/ /var/www/html/"$HOSTNAME".com
    echo "Iniciando Copia"
    cp /etc/content/. /var/www/html/"$HOSTNAME".com
}

firewalld_config()
{
    firewall-cmd --permanent --zone=public --add-port=80/tcp
    systemctl restart firewalld
    sed -i "s/$HOSTNAME/www."$HOSTNAME".com/g" /etc/hosts
    systemctl restart httpd
}

install_httpd
install_php
search_cp_dir
firewalld_config