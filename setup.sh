#!/usr/bin/env bash

pip_exec=$(which pip)
virtual_env_exec=$(which virtualenv)
virtual_env_path="${PWD}/tripleo_env"

if [[ -x ${virtual_env_exec} && -x ${pip_exec} ]]; then
  echo "${virtual_env_path} exists"
  echo "Creating virtual environment"
  ${virtual_env_exec} ${virtual_env_path}
  source ${virtual_env_path}/bin/activate
  pip install -r requirements.txt
  echo "Virtual environment setup complete"
else
  echo "Please install virtualenv and pip to continue"
fi