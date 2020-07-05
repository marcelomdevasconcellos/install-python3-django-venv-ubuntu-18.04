#!/bin/bash

export GIT="$1"
export PROJECT="$2"

echo "$GIT"
echo "$PROJECT"

#while [[ "$#" > 0 ]]; do
#    case $1 in
#        -g|--git) GIT="$2"; shift ;;
#        -p|--project) PROJECT="$1";  shift;;
#esac
#    shift
#done

if [[ "$GIT" ]] 
then
    echo "git: $GIT"
    echo "project: $PROJECT"
else
    echo "A variável não existe"
    exit
fi

cd /home
sudo apt update
sudo apt autoremove
python3 -V
sudo apt install python3-pip
sudo apt install python3-venv
sudo apt-get install apache2 libapache2-mod-wsgi-py3
sudo apt-get install python3-psycopg2 python-psycopg2-doc
pip3 install wheel
sudo apt-get install libpq-dev python-dev


python3 -m venv venv_$PROJECT
source /home/venv_$PROJECT/bin/activate
rm -rf /home/$PROJECT
git clone $GIT /home/$PROJECT
pip3 install -r /home/$PROJECT/requirements.txt

# Install PostgreSQL on Ubuntu 18.04 Server
# https://www.howtoforge.com/how-to-install-postgresql-and-pgadmin4-on-ubuntu-1804-lts/

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
sudo apt update
sudo apt -y install postgresql postgresql-contrib
sudo apt install pgadmin4 pgadmin4-apache2 -y

