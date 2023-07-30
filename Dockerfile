FROM holdenk/ray-x86-and-l4t:c21092023
# On ARM we _sometimes_ need to build the PostGres connector from source (depending on version).
RUN sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y libpq-dev libopenblas-dev
# Setup the dependencies in advance
RUN pip install torch ${PIP_EXTRA}
COPY requirements.txt /tmp/req.txt
# See https://github.com/python/typing/issues/573
RUN pip uninstall -y typing && CMAKE_ARGS="-DGGML_OPENBLAS=ON" pip install -U -r /tmp/req.txt ${PIP_EXTRA}
COPY model_setup.py ./
RUN python model_setup.py
