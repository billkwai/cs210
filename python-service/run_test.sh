#!/bin/sh
echo "Test suite executing..."
docker build -t foresight-test .
docker run -d --env APP_SETTINGS=testing --name foresight-app-test -p 8080:8080 foresight-test
docker exec foresight-app-test python3 test_app.py
docker rm -f foresight-app-test
echo "Test suite complete"