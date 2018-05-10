FROM ubuntu:latest
MAINTAINER Neel Bedekar "neel.bedekar@gmail.com"
RUN apt-get update -y
RUN apt-get install -y python3-pip python-dev build-essential
RUN apt-get install -y python python-pip python-virtualenv gunicorn


ENV APP_SETTINGS=production
ENV FLASK_APP=/app/run.py
COPY . /app
RUN pip3 install -r requirements.txt
WORKDIR /app
COPY gunicorn_config.py /app


EXPOSE 5000

CMD ["/usr/bin/gunicorn", "--config", "/app/gunicorn_config.py", "app:app"]