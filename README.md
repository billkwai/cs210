# lynx-code

Most of our backend lives in /python-service, which consists of a python web server built using Flask to create a REST Api, and which connects to our MySQL DB Server. The bulk of the necessary code is in app.py, which contains the web server logic, i.e. what happens when each endpoint is called. Most of this will be MySQL queries to retrieve and add information to our database, and much of the actual logic, such as security-related password hashing, will be in separate files altogether.
