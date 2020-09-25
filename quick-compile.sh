#!/bin/bash
if [[ -d venv ]]; then
  # Activate the virtual environment
  source venv/bin/activate
  # Compile the documentation
  make html
else
  echo "The virtual environment venv does not exist, please run ./compile.sh instead."
fi
