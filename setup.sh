#!/bin/bash

set -ex

export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=cpp

# On Jetson AGX we need to add /usr/local/cuda/bin to our path
if [ -f /usr/local/cuda/bin/nvcc ]; then
  export PATH=$PATH:/usr/local/cuda/bin
  export CUDA_HOME=/usr/local/cuda
fi

# See https://github.com/python/typing/issues/573
pip uninstall typing

# We need a modern pip and setuptools.
pip install --upgrade pip setuptools

# We need to install pybind11 before deepspeed because it is not listed as a depdency.
pip install pybind11[global]
if [ ! -d apex ]; then
  git clone https://github.com/NVIDIA/apex
fi

cd apex

pip install -v --disable-pip-version-check --no-cache-dir --no-build-isolation --config-settings "--build-option=--cpp_ext" --config-settings "--build-option=--cuda_ext" --config-settings "--build-option=--deprecated_fused_adam" ./

cd ..

pip install --upgrade ninja hjson py-cpuinfo

DS_BUILD_CPU_ADAM=1 DS_BUILD_SPARSE_ATTN=0 DS_BUILD_FUSED_ADAM=1 pip install "git+https://github.com/microsoft/deepspeed.git#" --global-option="build_ext" --global-option="-j16"

CMAKE_ARGS="-DGGML_OPENBLAS=ON" pip install --upgrade -r /tmp/requirements.txt --extra-index-url https://download.pytorch.org/whl/cu11${CU_MINOR}
