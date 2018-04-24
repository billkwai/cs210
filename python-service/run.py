import os

from app import create_app

config_name = os.getenv('APP_SETTINGS') # i.e. config_name = "production"
app = create_app(config_name)

if __name__ == '__main__':

  app.run(host='0.0.0.0', port=int(os.environ.get('PORT', '8080')))