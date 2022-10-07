import sys, getopt, os


def save_file(filename, content):
    file = open(filename, "w")
    file.write(content)
    file.close()


def read_file(filename):
    import codecs
    file = codecs.open(filename, "r", "utf-8")
    content = file.read()
    file.close()
    return content


PGADMIN_CONFIG = """
    
    WSGIDaemonProcess pgadmin processes=1 threads=25 python-home=/home/venv_pgadmin4
    WSGIScriptAlias /pgadmin4 /home/venv_pgadmin4/lib/python3.6/site-packages/pgadmin4/pgAdmin4.wsgi

    <Directory "/home/venv_pgadmin4/lib/python3.6/site-packages/pgadmin4/">
        WSGIProcessGroup pgadmin
        WSGIApplicationGroup %{GLOBAL}
        Require all granted
    </Directory>

"""

APACHE_CONFIG = """

    Alias /static /home/static
    <Directory /home/static>
        Require all granted
    </Directory>

    Alias /media /home/media
    <Directory /home/media>
        Require all granted
    </Directory>

    <Directory /home/%(project)s>
        <Files wsgi.py>
            Require all granted
        </Files>
    </Directory>

    WSGIDaemonProcess %(project)s python-home=/home/venv_%(project)s python-path=/home/%(project)s
    WSGIProcessGroup %(project)s
    WSGIScriptAlias / %(wsgi_path)s
    WSGIPassAuthorization On

</VirtualHost>
"""


def main(argv):
    project = ''
    try:
        opts, args = getopt.getopt(argv,"hp:",["project=",])
    except getopt.GetoptError:
        print('config_apache.py -p <project>')
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print('config_apache.py -p <project>')
            sys.exit()
        elif opt in ("-p", "--project"):
            project = arg
    print('Project is %s' % project)
    filename = '/etc/apache2/sites-available/000-default.conf'
    content = read_file(filename)
    data = {}
    data['project'] = project
    apps = os.listdir('/home/%s/' % project)
    data['wsgi_path'] = ''
    for app in apps:
        if os.path.isfile('/home/%s/%s/wsgi.py' % (project, app)):
            data['wsgi_path'] = '/home/%s/%s/wsgi.py' % (project, app)
    if data['wsgi_path']:
        new_content = PGADMIN_CONFIG + APACHE_CONFIG % data
        save_file(
            filename, 
            content.replace(
                '</VirtualHost>', 
                new_content)
            )
        print('Apache configured!')
    else:
        print('Apache cannot be configured!')


if __name__ == "__main__":
    main(sys.argv[1:])
