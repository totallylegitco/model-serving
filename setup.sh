#!/bin/bash

set -ex

export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=cpp

export CU_MINOR=$(nvcc --version |grep "cuda_" |cut -d "_" -f 2 |cut -d "." -f 2)
export TORCH_WHEEL_INDEX_URL="https://download.pytorch.org/whl/cu11${CU_MINOR}"
export PIP_EXTRA=${PIP_EXTRA:-"--pre --extra-index-url ${TORCH_WHEEL_INDEX_URL}"}

# On Jetson AGX we need to add /usr/local/cuda/bin to our path
if [ -f /usr/local/cuda/bin/nvcc ]; then
  export PATH=$PATH:/usr/local/cuda/bin
  export CUDA_HOME=/usr/local/cuda
fi

# See https://github.com/python/typing/issues/573
pip uninstall typing

# We need a modern pip and setuptools.
pip install --upgrade pip setuptools

CMAKE_ARGS="-DGGML_OPENBLAS=ON" pip install -r /tmp/requirements.txt ${PIP_EXTRA}
