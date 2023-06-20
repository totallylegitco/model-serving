#!/bin/bash
set -ex

nosetests -vs --traverse-namespace serve
flake8 serve --max-line-length=100   --ignore E265,W504
mypy serve
