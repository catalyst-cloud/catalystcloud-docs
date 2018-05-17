#!/bin/bash
# Demonstrates how to compile the documentation for local testing

# Check dependencies are installed
if ! which virtualenv; then
  echo "Could not find virtualenv on the PATH."
  echo "Try: apt-get instal python-virtualenv"
  exit 1
fi

if ! which pip; then
  echo "Could not find pip on the PATH."
  echo "Try: apt-get instal python-pipv"
  exit 1
fi

# Create a Python virtual environment if needed
if [ ! -d venv ]; then
  virtualenv venv
fi
# Activate the virtual environment
source venv/bin/activate

# Install the Python requirements on the virtual environment
pip install -r autobuild_requirements.txt

# Compile the documentation
make livehtml
