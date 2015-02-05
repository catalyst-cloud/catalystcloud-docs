#!/bin/bash
# Demonstrates how to compile the documentation for local testing

virtualenv venv
source venv/bin/activate
pip install -r requirements.txt
make html
