#!/usr/bin/env python
from app import app, config
from flask import Flask, json, current_app
from flask_testing import TestCase
import unittest

class FlaskAppTests(unittest.TestCase):

  @classmethod
  def setUpClass(cls):
      pass

  @classmethod
  def tearDownClass(cls):
      pass


  def setUp(self):
    # creates a test client
    # with self.app.app_context():
    #   self.test_app = current_app.test_client()
    # # propagate the exceptions to the test client
    # self.app.config['TESTING'] = True

    # reset database
    # self.app.get('/drop/all')
    # self.app.get('/players/setupdbs')
    
    self.app = app.test_client()
    self.app.testing = True
    self.app.config['TESTING'] = True
    

  def tearDown(self):
    # reset database
    # self.app.get('/drop/all')
    # self.app.get('/players/setupdbs')
    pass

  def test_home_status_code(self):
    # sends HTTP GET request to the application
    # on the specified path
    result = self.app.get('/')

    # assert the status code of the response
    self.assertEqual(result.status_code, 200)

  def test_home_data(self):
    # sends HTTP GET request to the application
    # on the specified path
    result = self.app.get('/')

    # assert the response data
    self.assertEqual(result.data.decode('UTF-8'), "The application is running!")

  def test_add_new_player(self):
    result = self.app.post('/players', data=json.dumps(dict(firstName='Bill', lastName='Kwai', username='billkwai', password='password', email='billkwai@stanford.edu', phone='8888888888', birthDate='1996-01-19')), content_type='application/json')
    #json_response = json.loads(result.get_data(as_text=True))
    self.assertEqual(result.status_code, 200)

  def test_get_new_player(self):
    result = self.app.get('/players/1')
    json_data = json.loads(result.get_data(as_text=True))
    self.assertEqual(result.status_code, 200)
    self.assertEqual(json_data['firstname'], "Bill")

if __name__ == '__main__':
    unittest.main()
