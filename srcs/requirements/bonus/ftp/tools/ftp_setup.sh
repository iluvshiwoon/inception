#!/usr/bin/env python3

import os
import sys
from pyftpdlib.authorizers import DummyAuthorizer
from pyftpdlib.handlers import FTPHandler
from pyftpdlib.servers import FTPServer

FTP_USER = os.environ.get('FTP_USER', 'kgriset_ftp')
FTP_PASSWORD = os.environ.get('FTP_PASSWORD', 'password')

authorizer = DummyAuthorizer()
authorizer.add_user(FTP_USER, FTP_PASSWORD, '/var/www/html', perm='elr')

handler = FTPHandler
handler.authorizer = authorizer
handler.passive_ports = range(40000, 40006)

server = FTPServer(('0.0.0.0', 21), handler)
server.max_cons = 256
server.max_cons_per_ip = 5

print(f"Starting FTP server for user {FTP_USER}")
sys.stdout.flush()
server.serve_forever()