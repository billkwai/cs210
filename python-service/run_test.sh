#!/bin/sh
echo "Test suite executing..."
docker build -t foresight-test .
docker run -d --name foresight-app-test -p 8080:8080 foresight-test app.py -test
docker exec foresight-app-test python3 -m unittest discover
docker rm -f foresight-app-test
echo "Test suite complete"