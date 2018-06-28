from flask import Flask

import argparse
import socket
import sys


def check_arg(args=None):
    parser = argparse.ArgumentParser(
            description='Simple Flask app to test load balancer service')
    parser.add_argument('-p', '--port',
                        required='True',
                        help='port for the web server to bind to')

    results = parser.parse_args(args)
    return (results.port)


host_name = socket.gethostname()
host_ip = socket.gethostbyname(host_name)

app = Flask(__name__)


@app.route("/")
def hello():
    return "Server : {} @ {}".format(host_name, host_ip)


@app.route("/health")
def health():
    return "healthy!"


if __name__ == '__main__':
    p = check_arg(sys.argv[1:])
    app.run(host='0.0.0.0', port=p)
