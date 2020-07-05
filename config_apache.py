import sys, getopt

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

if __name__ == "__main__":
   main(sys.argv[1:])