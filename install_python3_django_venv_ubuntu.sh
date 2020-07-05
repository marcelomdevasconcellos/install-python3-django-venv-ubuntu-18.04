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

cd ~/
sudo apt update
sudo apt autoremove
python3 -V
sudo apt install python3-pip
sudo apt install python3-venv
sudo apt-get install python3-psycopg2
pip install -r requirements.txt 
sudo apt-get install libpq-dev python-dev


python3 -m venv venv_$PROJECT
source venv_$PROJECT/bin/activate
rm -rf ~/$PROJECT
git clone $GIT ~/$PROJECT
pip install -r ~/$PROJECT/requirements.txt

