#! /bin/bash
#Indentifica o apache na maquina, o desisnstala e instala a versão mais recente.
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

# Cria o vhost para o site e configura o nome do site e a localização da pasta.
vhost_creation()
{
    echo -e "<VirtualHost *:80>\n   ServerName www.$HOSTNAME.com\n   DocumentRoot "/var/www/html/$HOSTNAME.com"\n</VirtualHost>" >> /etc/httpd/conf.d/"$HOSTNAME".com.conf
}

# Cria os diretórios do site e puxa de etc/content o conteudo do site
create_dir()
{
    mkdir /var/www/html/"$HOSTNAME".com
    chown -R apache:apache /var/www/html/"$HOSTNAME".com
    mkdir /etc/content
    rsync -a /etc/content/ /var/www/html/"$HOSTNAME".com
}

# Configura o firewall e o arquivo etc/hosts
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