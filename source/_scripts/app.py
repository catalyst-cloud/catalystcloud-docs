#!/usr/bin/env python
from flask import Flask
import socket

app = Flask(__name__)

host_name = socket.gethostname()
host_ip = socket.gethostbyname(host_name)


@app.route("/")
def hello_world():
  return "Hello World! From Server : {} @ {}".format(host_name, host_ip)

if __name__ == "__main__":
  app.run(host='0.0.0.0')
