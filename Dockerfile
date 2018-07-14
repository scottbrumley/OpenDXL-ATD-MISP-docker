FROM alpine


RUN apk update

RUN apk add --no-cache python3 && \
    apk add bash && \
    apk add curl && \
    apk add git && \
    apk add gcc && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    rm -r /root/.cache

#RUN apk add --no-cache curl python pkgconfig python-dev openssl-dev libffi-dev musl-dev make gcc
#RUN pip install setuptools

# Set the lang, you can also specify it as as environment variable through docker-compose.yml
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8


# Install PyMISP
RUN git clone https://github.com/MISP/PyMISP.git
RUN cd PyMISP/; python setup.py install

# Install Requests
RUN pip install requests

# Install OpenDXL Python client
RUN git clone https://github.com/opendxl/opendxl-client-python.git
RUN cd opendxl-client-python/; python setup.py install

# Install OpenDXL bootstrap
RUN git clone https://github.com/opendxl/opendxl-bootstrap-python.git
RUN cd opendxl-bootstrap-python/;python setup.py install

ADD config/brokercerts.crt /config/brokercerts.crt
ADD config/client.crt /config/client.crt
ADD config/client.key /config/client.key
ADD config/dxlclient.config /config/dxlclient.config

# Install MISP MAR script
RUN git clone https://github.com/mohlcyber/OpenDXL-ATD-MISP.git
WORKDIR /OpenDXL-ATD-MISP

RUN sed -i 's/https:\/\/misp-url\//https:\/\/misp\//g' misp.py
RUN sed -i 's/api-key/MvQeHbndoW0CkArWnPy8wxG2ea5XHZFwUIm0ITYY/g' misp.py
RUN sed -i 's/path to dxlclient config file/\/config\/dxlclient.config/g' atd_subscriber.py
RUN cat atd_subscriber.py

ENTRYPOINT ["python"]
CMD ["atd_subscriber.py"]
