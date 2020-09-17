import argparse
import socket
import sys

from flask import Flask


def check_arg(args=None):
    parser = argparse.ArgumentParser(
        description='Simple Flask app to test load balancer service')
    parser.add_argument('-p', '--port',
                        required='True',
                        help='port for the web server to bind to')
    parser.add_argument('-u', '--url',
                        default=None,
                        help='url for the server to respond with')
    results = parser.parse_args(args)
    return (results.port, results.url)


host_name = socket.gethostname()
host_ip = socket.gethostbyname(host_name)

app = Flask(__name__)


@app.route("/")
def hello():
    if server_url is None:
        return "Server : {} @ {}".format(host_name, host_ip)
    else:
        return "Welcome to {} @ {}".format(server_url, host_ip)


@app.route("/health")
def health():
    return "healthy!"


if __name__ == '__main__':
    server_port, server_url = check_arg(sys.argv[1:])
    app.run(host='0.0.0.0', port=server_port)
