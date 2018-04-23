FROM ubuntu:latest
MAINTAINER Neel Bedekar "neel.bedekar@gmail.com"
RUN apt-get update -y
RUN apt-get install -y python3-pip python-dev build-essential
ENV APP_SETTINGS=production
ENV FLASK_APP=/app/run.py
COPY . /app
WORKDIR /app
RUN pip3 install -r requirements.txt
ENTRYPOINT ["python3", "run.py"]