FROM holdenk/ray-x86-and-l4t:c21092023
# On ARM we _sometimes_ need to build the PostGres connector from source (depending on version).
RUN sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y libpq-dev libopenblas-dev
# Setup the dependencies in advance
RUN pip install torch ${PIP_EXTRA}
COPY requirements.txt /tmp/
COPY setup.sh ./
RUN ./setup.sh
COPY model_setup.py ./
RUN python model_setup.py
