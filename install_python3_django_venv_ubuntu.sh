#!/bin/bash

export GIT="$1"
export PROJECT="$2"

if [[ "$GIT" ]] 
then
    echo "git: $GIT"
    echo "project: $PROJECT"
else
    echo "A variável não existe"
    exit
fi

sudo apt update
sudo apt autoremove
python3 -V
sudo apt install python3-pip
sudo apt install python3-venv
sudo apt-get install apache2 libapache2-mod-wsgi-py3
sudo apt-get install python3-psycopg2 python-psycopg2-doc
pip3 install wheel
sudo apt-get install libpq-dev python-dev
python3 -m venv /home/venv_$PROJECT
source /home/venv_$PROJECT/bin/activate
rm -rf /home/$PROJECT
git clone $GIT /home/$PROJECT
pip3 install -r /home/$PROJECT/requirements.txt
mkdir /home/static
mkdir /home/media
cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default_backup
sudo chown :www-data /home/$PROJECT
python3 config_apache.py -p $PROJECT
sudo ufw delete allow 8000
sudo ufw allow 'Apache Full'
sudo apache2ctl configtest
sudo systemctl restart apache2

# Install PostgreSQL on Ubuntu 18.04 Server
# https://www.howtoforge.com/how-to-install-postgresql-and-pgadmin4-on-ubuntu-1804-lts/

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
sudo apt update
sudo apt -y install postgresql postgresql-contrib
sudo apt install pgadmin4 pgadmin4-apache2 -y

