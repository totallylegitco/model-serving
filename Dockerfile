FROM rayproject/ray:latest-py310-gpu
# On ARM we _sometimes_ need to build the PostGres connector from source (depending on version).
RUN sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y libpq-dev libopenblas-dev
# Setup the dependencies in advance
COPY requirements.txt /tmp/req.txt
# See https://github.com/python/typing/issues/573
RUN pip uninstall -y typing
RUN CMAKE_ARGS="-DGGML_OPENBLAS=ON" pip install -U -r /tmp/req.txt
