#!/bin/bash
# Demonstrates how to compile the documentation for local testing

platform='unknown'
unamestr=`uname`

# Check dependencies are installed
if [[ "$unamestr" == 'Linux' ]]; then
  if [[ -z $(dpkg -l |grep python3-venv) ]]; then
    echo "Could not find python3-venv on the PATH."
    echo "Try: apt install python3-venv"
    exit 1
  fi
elif [[ "$unamestr" == 'Darwin' ]]; then
  echo "pass"
fi

if ! which pip3; then
  echo "Could not find pip3 on the PATH."
  echo "Try: apt install python3-pip"
  exit 1
fi

# Create a Python virtual environment if needed
if [ ! -d venv ]; then
    python3 -m venv venv
fi

# Activate the virtual environment
source venv/bin/activate

# Install the Python requirements on the virtual environment
pip install -r requirements.txt

# Compile the documentation
make livehtml
