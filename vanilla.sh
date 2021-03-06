#!/bin/sh
{
    echo "This script requires superuser access to install apt packages."
    echo "You will be prompted for your password by sudo if a password is required."

    # clear any previous sudo permission
    sudo -k

    # run inside sudo
    sudo sh <<SCRIPT

    set -e

    echo "updating apt-get..."
    apt-get update 1>/dev/null

    echo "installing add-apt-repository..."
    apt-get -y install software-properties-common python-software-properties 1>/dev/null

    echo "adding apt repository ppa:nginx/development..."
    add-apt-repository -y ppa:nginx/development 1>/dev/null

    echo "updating apt-get..."
    apt-get update 1>/dev/null

    echo "installing the latest nginx..."
    apt-get -y install nginx 1>/dev/null
    chown -R www-data:www-data /var/lib/nginx

    echo "installing other requirements: git python3 python3-pip libssl-dev libpcre3-dev letsencrypt..."
    apt-get -y install git python3 python3-pip libssl-dev libpcre3-dev letsencrypt 1>/dev/null

    echo "installing python requirements: pyinotify..."
    pip3 install pyinotify

    echo "cloning nginx-pages..."
    git clone https://github.com/samuelcolvin/nginx-pages /nginx-pages 1>/dev/null

    echo "adding user 'bob'..."
    useradd -m bob

    echo "adding redirect site to nginx..."
    rm /etc/nginx/sites-enabled/default
    cp /nginx-pages/nginx-conf/redirect /etc/nginx/sites-available/
    ln -s /etc/nginx/sites-available/redirect /etc/nginx/sites-enabled/

    echo "adding watch.service to systemd and enabling it..."
    cp /nginx-pages/watch.service /etc/systemd/system/
    systemctl enable watch

    echo "generating unique primes for ssl, this might be very slow. Hold tight..."
    openssl dhparam -out /nginx-pages/dhparams.pem 2048

SCRIPT
}
