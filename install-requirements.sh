#!/bin/sh

set -o errexit
set -o xtrace

git submodule init
git submodule update

venv_path=.venv

python3 -m venv "${venv_path}"

python="${venv_path}/bin/python"

"${python}" -m pip install --upgrade pip
"${python}" -m pip install --requirement=requirements.txt

ansible_galaxy="${venv_path}/bin/ansible-galaxy"

"${ansible_galaxy}" collection install \
    --collections-path=collections \
    --requirements-file=requirements.yml
"${ansible_galaxy}" role install \
    --roles-path=roles \
    --role-file=requirements.yml

packer init .
