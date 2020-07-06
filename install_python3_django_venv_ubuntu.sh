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

sudo apt-get update
sudo apt-get upgrade
sudo apt-get dist-upgrade
sudo apt autoremove
python3 -V
sudo apt -y install python3-pip python3-venv
sudo apt-get install apache2 libapache2-mod-wsgi-py3 libpq-dev python-dev
pip3 install wheel
python3 -m venv /home/venv_$PROJECT

source /home/venv_$PROJECT/bin/activate
pip3 install psycopg2-binary
rm -rf /home/$PROJECT
git clone $GIT /home/$PROJECT
pip3 install -r /home/$PROJECT/requirements.txt
deactivate

mkdir /home/static
mkdir /home/media
cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default_backup
sudo chown www-data:www-data /home/$PROJECT
sudo chown www-data:www-data /home/static
sudo chown www-data:www-data /home/media

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
sudo apt update
sudo apt -y install postgresql postgresql-contrib

sudo apt update
sudo apt -y install libgmp3-dev libpq-dev libapache2-mod-wsgi-py3
sudo mkdir -p /var/lib/pgadmin4/sessions
sudo mkdir /var/lib/pgadmin4/storage
sudo mkdir /var/log/pgadmin4
sudo adduser $PROJECT
sudo chown -R $PROJECT:$PROJECT /var/lib/pgadmin4
sudo chown -R $PROJECT:$PROJECT /var/log/pgadmin4
python3 -m venv /home/venv_pgadmin4
source /home/venv_pgadmin4/bin/activate
wget https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v4.23/pip/pgadmin4-4.23-py3-none-any.whl
python -m pip install wheel
python -m pip install pgadmin4-4.23-py3-none-any.whl
echo "LOG_FILE = '/var/log/pgadmin4/pgadmin4.log'" >> /home/venv_pgadmin4/lib/python3.6/site-packages/pgadmin4/config_local.py
echo "SQLITE_PATH = '/var/lib/pgadmin4/pgadmin4.db'" >> /home/venv_pgadmin4/lib/python3.6/site-packages/pgadmin4/config_local.py
echo "SESSION_DB_PATH = '/var/lib/pgadmin4/sessions'" >> /home/venv_pgadmin4/lib/python3.6/site-packages/pgadmin4/config_local.py
echo "STORAGE_DIR = '/var/lib/pgadmin4/storage'" >> /home/venv_pgadmin4/lib/python3.6/site-packages/pgadmin4/config_local.py
echo "SERVER_MODE = True" >> /home/venv_pgadmin4/lib/python3.6/site-packages/pgadmin4/config_local.py
pip install werkzeug==0.16.0
python /home/venv_pgadmin4/lib/python3.6/site-packages/pgadmin4/setup.py
deactivate
sudo chown -R www-data:www-data /var/lib/pgadmin4/
sudo chown -R www-data:www-data /var/log/pgadmin4/
sudo /etc/init.d/postgresql start
pg_ctlcluster 12 main start
sudo -u postgres psql -c "CREATE ROLE $PROJECT;"
sudo -u postgres psql -c "ALTER USER $PROJECT PASSWORD '$PROJECT';"
sudo -u postgres psql -c "CREATE DATABASE $PROJECT;"
sudo -u postgres psql -c "ALTER DATABASE $PROJECT OWNER TO $PROJECT;"
sudo -u postgres psql -c "ALTER ROLE $PROJECT WITH LOGIN;"
python3 config_apache.py -p $PROJECT
sudo ufw delete allow 8000
sudo ufw allow 'Apache Full'
sudo apache2ctl configtest
sudo systemctl restart apache2
sudo dpkg-reconfigure locales

