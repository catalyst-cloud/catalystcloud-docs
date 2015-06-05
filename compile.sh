#!/bin/bash
# Demonstrates how to compile the documentation for local testing

# Create a Python virtual environment
virtualenv venv
source venv/bin/activate

# Install the Python requirements on the virtual environment
pip install -r requirements.txt

# Compile the documentation
make html
