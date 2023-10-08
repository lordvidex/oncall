# dockerfile for launching the script for containers.py
FROM docker:24-cli

# Install python3 and pip3
RUN apk add --no-cache python3 py3-pip
COPY ./containers.py /containers.py

ENTRYPOINT ["python3", "/containers.py"]


