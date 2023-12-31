FROM holdenk/ray-x86-and-l4t:a30082023
# On ARM we _sometimes_ need to build the PostGres connector from source (depending on version).
RUN sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y libpq-dev libopenblas-dev libprotobuf-dev libprotobuf-c-dev python3-protobuf
COPY requirements.txt /tmp/
COPY setup.sh ./
RUN ./setup.sh
COPY model_setup.py ./
RUN python model_setup.py
COPY serve/* ./
