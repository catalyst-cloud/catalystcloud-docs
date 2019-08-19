#!/bin/bash
# This script assume that the full compile script has run recently and the 
# required venv has been correctly created

# Activate the virtual environment
source venv/bin/activate

# Compile the documentation
make html
