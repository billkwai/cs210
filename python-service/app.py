#!/usr/bin/env python
from __future__ import print_function
from flask import Flask, jsonify, abort, request
from flask_cors import CORS, cross_origin
import config

#import mysql.connector
#from mysql.connector import errorcode

import logging
import pymysql
import sys, os
import hashlib, binascii, base64
#import bcrypt
#from argon2 import PasswordHasher
import bcrypt

def create_app(config_name):
  app = Flask(__name__)
  app_config = {
    'development': 'config.config.DevelopmentConfig',
    'testing': 'config.config.TestingConfig',
    'staging': 'config.config.StagingConfig',
    'production': 'config.config.ProductionConfig'
  }
  app.config.from_object(app_config.get(config_name, 'config.TestingConfig'))
  CORS(app)
  cors = CORS(app, resources={r"/api/*": {"origins": "*","methods":"POST,DELETE,PUT,GET,OPTIONS"}})

  NO_INITIAL_COINS = 2500.0
  INITIAL_PICK_BUFFER = 250
  USERNAME_INVALID = -1
  USERNAME_VALID = 1
  POST_SUCCESSFUL = 1
  PUT_SUCCESSFUL = 1
  DELETE_SUCCESSFUL = 1
  PASSWORD_INCORRECT = -2
  PASSWORD_CORRECT = 1
  DB_EXCEPTION_THROWN = -3
  API_KEY_LENGTH = 32
  NUM_LEADERBOARD_ALL = 100
  EMAIL_EXISTS = -4
  USERNAME_EXISTS = -5


  #DB_NAME = 'employees'

  TABLES = {}
  TABLES['employees'] = (
      "CREATE TABLE `employees` ("
      "  `emp_no` int(11) NOT NULL AUTO_INCREMENT,"
      "  `birth_date` date NOT NULL,"
      "  `first_name` varchar(14) NOT NULL,"
      "  `last_name` varchar(16) NOT NULL,"
      "  `gender` enum('M','F') NOT NULL,"
      "  `hire_date` date NOT NULL,"
      "  PRIMARY KEY (`emp_no`)"
      ") ENGINE=InnoDB")




  def creatConnection():
      # Read MySQL Environment Parameters
      connectString = None
      if app.config['TESTING']:
        connectString = os.environ.get('MYSQLCS_CONNECT_STRING', '129.150.88.243:/mydatabase')
      else:
        connectString = os.environ.get('MYSQLCS_CONNECT_STRING', '129.150.120.63:/mydatabase')
      hostname = connectString[:connectString.index(":")]#'129.150.120.63'#
      database = connectString[connectString.index("/")+1:]#'mydatabase'#
      #print("Hostname = "+hostname+", database = "+database)
      #return os.environ.get('MYSQLCS_MYSQL_PORT', '3306') + os.environ.get('MYSQLCS_USER_NAME', 'root') + os.environ.get('MYSQLCS_USER_PASSWORD', '') + hostname+' '+database+'\n'
      #return 'Inside mid of creatConnection'
      #print (pymysql.cursors.DictCursor == None, pymysql.cursors.DictCursor)
      #return 'Pre created conn'
      #cnx = mysql.connector.connect(user='root', #os.environ.get('MYSQLCS_USER_NAME', 'root'),
       #                         password=os.environ.get('MYSQLCS_USER_PASSWORD', 'lynx1N{}'),
        #                        host=hostname,
         #                       database=db)

      port=int(os.environ.get('MYSQLCS_MYSQL_PORT', '3306'))
      user=os.environ.get('MYSQLCS_USER_NAME', 'root')
      passwd=os.environ.get('MYSQLCS_USER_PASSWORD', 'lynx1N{}')
      #return "Hostname = "+hostname+", database = "+database+", port = "+str(port)+", user = "+user+", passwd = "+passwd
      conn = pymysql.connect(host=hostname, 
                             #port=port,
                             user=user, 
                             passwd=passwd,
                             db=database,
                             cursorclass=pymysql.cursors.DictCursor)
      #print( "Hostname = "+hostname+", database = "+database+", port = "+str(port)+", user = "+user+", passwd = "+passwd)


      #return 'Inside created conn'
      #conn.close()
      return conn;
      #return cnx;

  @app.route('/')
  def index():
      #print ("Request header is: %s" % request.headers.get('Authorization'))
      str_pass = "pass"
      bytes_pass = str_pass.encode('utf-8')
      hashed = bcrypt.hashpw(bytes_pass, bcrypt.gensalt())

      if bcrypt.checkpw(b'pass', hashed):
        print ("It matches!")
      else:
        print ("It doesn't match!")


      return 'The application is running!'

  @app.route('/drop/players')
  def drop_players():
      conn = creatConnection()
      cur = conn.cursor()
      cur.execute('''DROP TABLE IF EXISTS PLAYERS;''')
      cur.close()
      conn.close()
      return 'Succesfully dropped players'

  @app.route('/drop/colleges')
  def drop_colleges():
      conn = creatConnection()
      cur = conn.cursor()
      cur.execute('''DROP TABLE IF EXISTS COLLEGES;''')
      cur.close()
      conn.close()
      return 'Succesfully dropped colleges'
    
  @app.route('/drop/companies')
  def drop_companies():
      conn = creatConnection()
      cur = conn.cursor()
      cur.execute('''DROP TABLE IF EXISTS COMPANIES;''')
      cur.close()
      conn.close()
      return 'Succesfully dropped companies'

  # endpoint to drop all tables in database. BE CAREFUL WHEN USING
  @app.route('/drop/all')
  def drop_all():
      conn = creatConnection()
      cur = conn.cursor()
      cur.execute('''DROP TABLE IF EXISTS COLLEGES;''')
      cur.execute('''DROP TABLE IF EXISTS COMPANIES;''')
      cur.execute('''DROP TABLE IF EXISTS PLAYERS;''')
      cur.execute('''DROP TABLE IF EXISTS FRIENDS;''')
      cur.execute('''DROP TABLE IF EXISTS CATEGORIES;''')
      cur.execute('''DROP TABLE IF EXISTS ENTITIES;''')
      cur.execute('''DROP TABLE IF EXISTS EVENTS;''')
      cur.execute('''DROP TABLE IF EXISTS PICKS;''')
      cur.close()
      conn.close()
      return 'Successfully dropped all tables'

  @app.route('/players/setupdbs')
  def setupDBS():
      print("Reached players/setupdb endpoint")
      #return creatConnection()
      conn = creatConnection()
      #return conn
      #cnx = creatConnection()
      cur = conn.cursor()
      #cursor = cnx.cursor()

  #    for name, ddl in TABLES.items():
   #       try:
    #          print("Creating table {}: ".format(name), end='')
     #         cursor.execute(ddl)
      #    except mysql.connector.Error as err:
       #       if err.errno == errorcode.ER_TABLE_EXISTS_ERROR:
        #          print("already exists")
         #     else:
          #        print(err.msg)
          #else:
           #   print("OK")
   
      cur.execute('''CREATE TABLE COLLEGES (
                    id INTEGER NOT NULL AUTO_INCREMENT,
                    name VARCHAR(255) NOT NULL,
                    PRIMARY KEY (id)
                    ) ENGINE=INNODB; ''')

      cur.execute('''CREATE TABLE COMPANIES (
                    id INTEGER NOT NULL AUTO_INCREMENT,
                    name VARCHAR(255) NOT NULL,
                    PRIMARY KEY (id)
                    ) ENGINE=INNODB; ''')

      cur.execute('''CREATE TABLE PLAYERS (
                    id INTEGER NOT NULL AUTO_INCREMENT,
                    firstname VARCHAR(255) NOT NULL,
                    lastname VARCHAR(255) NOT NULL,
                    username VARCHAR(255) NOT NULL,
                    password VARCHAR(255) NOT NULL,
                    salted VARCHAR(255) NOT NULL,
                    email VARCHAR(255),
                    phone VARCHAR(255),
                    birthdate VARCHAR(10),
                    college_id INT,
                    company_id INT,
                    coins FLOAT NOT NULL,
                    api_key VARCHAR(255),
                    PRIMARY KEY (id),
                    FOREIGN KEY (college_id) REFERENCES COLLEGES(id)
                    ON UPDATE CASCADE ON DELETE RESTRICT,
                    FOREIGN KEY (company_id) REFERENCES COMPANIES(id)
                    ON UPDATE CASCADE ON DELETE RESTRICT
                    ) ENGINE=INNODB; ''')

      cur.execute('''CREATE TABLE FRIENDS (
                    friend1_id INTEGER NOT NULL,
                    friend2_id INTEGER NOT NULL,
                    PRIMARY KEY (friend1_id, friend2_id),
                    FOREIGN KEY (friend1_id) REFERENCES PLAYERS(id)
                    ON UPDATE CASCADE ON DELETE CASCADE,
                    FOREIGN KEY (friend2_id) REFERENCES PLAYERS(id)
                    ON UPDATE CASCADE ON DELETE CASCADE
                    ) ENGINE=INNODB; ''')


      cur.execute('''CREATE TABLE CATEGORIES (
                    id INTEGER NOT NULL AUTO_INCREMENT,
                    name VARCHAR(255) NOT NULL,
                    PRIMARY KEY (id)
                    ) ENGINE=INNODB; ''')


      cur.execute('''CREATE TABLE ENTITIES (
                    id INTEGER NOT NULL AUTO_INCREMENT,
                    name VARCHAR(255) NOT NULL,
                    category_id INTEGER NOT NULL,
                    PRIMARY KEY (id),
                    FOREIGN KEY (category_id) REFERENCES CATEGORIES(id)
                    ON UPDATE CASCADE ON DELETE RESTRICT
                    ) ENGINE=INNODB; ''')
      
      try:
        cur.execute('''CREATE TABLE EVENTS (
                    id INTEGER NOT NULL AUTO_INCREMENT,
                    event_title VARCHAR(255) NOT NULL,
                    entity1_id INTEGER NOT NULL,
                    entity2_id INTEGER NOT NULL,
                    category_id INTEGER NOT NULL,
                    event_time TIMESTAMP NOT NULL,
                    entity1_pool INTEGER NOT NULL,
                    entity2_pool INTEGER NOT NULL,
                    picking_active  BOOL NOT NULL,
                    event_active  BOOL  NOT NULL,
                    winning_entity INTEGER,
                    PRIMARY KEY (id),
                    FOREIGN KEY (entity1_id) REFERENCES ENTITIES(id)
                    ON UPDATE CASCADE ON DELETE RESTRICT,
                    FOREIGN KEY (entity2_id) REFERENCES ENTITIES(id)
                    ON UPDATE CASCADE ON DELETE RESTRICT,
                    FOREIGN KEY (category_id) REFERENCES CATEGORIES(id)
                    ON UPDATE CASCADE ON DELETE RESTRICT
                    ) ENGINE=INNODB; ''')

        cur.execute('''CREATE TABLE PICKS (
                    id INTEGER NOT NULL AUTO_INCREMENT,
                    player_id INTEGER NOT NULL,
                    event_id INTEGER NOT NULL,
                    picked_entity INTEGER NOT NULL,
                    entity1_pool  INTEGER NOT NULL,
                    entity2_pool  INTEGER NOT NULL,
                    correct_payout  FLOAT NOT NULL,
                    bet_size INTEGER NOT NULL,
                    pick_timestamp TIMESTAMP NOT NULL,
                    pick_correct BOOL,
                    PRIMARY KEY (id),
                    FOREIGN KEY (player_id) REFERENCES PLAYERS(id)
                    ON UPDATE CASCADE ON DELETE RESTRICT,
                    FOREIGN KEY (event_id) REFERENCES EVENTS(id)
                    ON UPDATE CASCADE ON DELETE RESTRICT
                    ) ENGINE=INNODB; ''')
        
      except Exception as e:
        print(e)




      conn.commit()
      cur.close()
      #cursor.close()
      #cnx.close()
      conn.close()
      return 'The PLAYERS table was created succesfully'
      
  @app.route('/players')
  def players():
      print("Reached players endpoint")
      conn = creatConnection()
      cur = conn.cursor()
      cur.execute('''SELECT * FROM PLAYERS''')
      results = cur.fetchall()    
      cur.close()
      conn.close()
      return jsonify( results)    

  @app.route('/players/<int:player_id>', methods=['GET'])
  def get_player(player_id):
      conn = creatConnection()
      cur = conn.cursor()
      cmd_str = 'SELECT * FROM PLAYERS WHERE ID = %s'
      cur.execute(cmd_str, (player_id))
      rv = cur.fetchone()
      if rv is None:
          abort(404)
      cur.close()
      conn.close()
      return jsonify( rv) 

  @app.route('/colleges/fill_our_data')
  def fill_our_data_colleges():
      conn = creatConnection()
      cur = conn.cursor()
      cur.execute("INSERT INTO colleges (name) VALUES (\"Stanford\"), (\"University of California, Berkeley\"), (\"University of California, Los Angeles\"), (\"The Ohio State University\"), (\"Arizona State University\"), (\"Harvard University\");")
      conn.commit()
      cur.close()
      conn.close()
      return "Successfully added the data"


  @app.route('/companies/fill_our_data')
  def fill_our_data_companies():
      conn = creatConnection()
      cur = conn.cursor()
      cur.execute("INSERT INTO companies (name) VALUES (\"Oracle\"), (\"Facebook\");")
      conn.commit()
      cur.close()
      conn.close()
      return "Successfully added the data"


  @app.route('/categories')
  def get_categories():
      conn = creatConnection()
      cur = conn.cursor()
      cmd_str = '''SELECT * FROM CATEGORIES WHERE NAME = 'SPORTS' OR NAME = 'POLITICS'
      OR NAME = 'POP CULTURE'; '''

      cur.execute(cmd_str)
      rv = cur.fetchall()
      if rv is None:
          abort(404)
      cur.close()
      conn.close()
      return jsonify( rv) 

  @app.route('/players/<int:player_id>/picks', methods=['POST'])
  def make_pick(player_id):
      conn = creatConnection()
      cur = conn.cursor()
      try:
          entity1_pool = request.json['entity1_pool']
          entity2_pool = request.json['entity2_pool']
          bet_size = request.json['bet_size']
          event_id = request.json['event_id']
          picked_entity = request.json['picked_entity']
          entity1_id = request.json['entity1_id']
          entity2_id = request.json['entity2_id']
          denom =  entity1_pool if (picked_entity == entity1_id) else entity2_pool
          payout = (float(entity1_pool + entity2_pool) / float(denom)) * bet_size

          cmd_str = '''INSERT INTO PICKS (player_id, event_id, picked_entity, entity1_pool, entity2_pool, correct_payout, bet_size, pick_timestamp)
                      VALUES(%s, %s, %s, %s, %s, %s, %s, UTC_TIMESTAMP())'''
          cur.execute(cmd_str, (player_id, event_id, picked_entity, entity1_pool, entity2_pool, payout, bet_size))
          
          if (picked_entity == entity1_id):
              cmd_str2 = '''UPDATE EVENTS SET entity1_pool = entity1_pool + %s WHERE id = %s;'''
              cur.execute(cmd_str2, (bet_size, event_id))
          else:
              cmd_str2 = '''UPDATE EVENTS SET entity2_pool = entity2_pool + %s WHERE id = %s;'''
              cur.execute(cmd_str2, (bet_size, event_id))

          cmd_str3 = '''UPDATE PLAYERS SET coins = coins - %s WHERE id = %s;'''
          cur.execute(cmd_str3, (bet_size, player_id))

          conn.commit()
          message = {'status': POST_SUCCESSFUL, 'message' : 'The pick record was created succesfully'}
      except Exception as e:
          logging.error('DB exception: %s' % e)   
          message = {'status': DB_EXCEPTION_THROWN, 'message': 'Pick creation failed.'}

      cur.close()
      conn.close()
      return jsonify(message)


  @app.route('/players/<int:player_id>/picks', methods =['GET'])
  def get_past_events(player_id):
      conn = creatConnection()
      cur = conn.cursor()
      cur.execute(''' SELECT e.id AS event_id, e.event_title, one.id AS entity1_id, e.picking_active, e.event_active,
        p.pick_correct, one.name as entity1_name, two.id AS entity2_id, two.name as entity2_name,
        p.pick_timestamp, p.picked_entity, p.entity1_pool,p.entity2_pool,p.correct_payout, p.bet_size
        FROM EVENTS AS e JOIN ENTITIES AS one ON e.entity1_id = one.id JOIN ENTITIES AS two ON e.entity2_id = two.id
        JOIN PICKS AS p ON e.id = p.event_id WHERE player_id = %d
        ORDER BY pick_timestamp DESC; ''' % (player_id))
      #cur.execute(''' SELECT EVENTS.id, entity1_id, entity2_id, category_id, event_time,
       #   EVENTS.entity1_pool, EVENTS.entity2_pool, active FROM EVENTS
        #  LEFT JOIN PICKS ON (EVENTS.id = PICKS.event_id AND PICKS.player_id = %d)
         # WHERE PICKS.event_id IS NULL; ''' % (player_id))

      rv = cur.fetchall()

      cur.close()
      conn.close()

      return jsonify(rv)

  @app.route('/players/<int:player_id>/picks/stats', methods =['GET'])
  def get_picks_stats(player_id):
      conn = creatConnection()
      cur = conn.cursor()

      cur_string = '''  SELECT ( SELECT COUNT(*) FROM PICKS WHERE player_id = %s AND pick_correct = 1)
      AS correct_ever, ( SELECT COUNT(*) FROM PICKS WHERE player_id = %s AND pick_correct = 0) AS incorrect_ever,
      ( SELECT COUNT(*) FROM PICKS WHERE player_id = %s AND pick_correct = 0
      AND TIMESTAMPDIFF(DAY,pick_timestamp, UTC_TIMESTAMP()) < 7) AS incorrect_weekly,
      ( SELECT COUNT(*) FROM PICKS WHERE player_id = %s AND pick_correct = 1
      AND TIMESTAMPDIFF(DAY,pick_timestamp, UTC_TIMESTAMP()) < 7)  AS correct_weekly;  '''

      cur.execute(cur_string, (player_id, player_id, player_id, player_id));

      rv = cur.fetchone()

      cur.close()
      conn.close()

      return jsonify(rv)

  @app.route('/events/<int:event_id>/broadcast_result', methods = ['POST'])
  def broadcast_event_result(event_id):
      conn = creatConnection()
      cur = conn.cursor()
      winning_entity = request.json['winning_entity']
      #print ("The id is %d and entity1_won is %d"%(event_id, winning_entity))
      try:
          cur.execute(''' UPDATE EVENTS SET event_active = 0, winning_entity = %d WHERE id = %d;''' % (winning_entity, event_id))
          print ("The id is %d and winning_entity is %d"%(event_id, winning_entity))

          cur.execute(''' UPDATE PICKS SET pick_correct = IF(PICKS.picked_entity = %d, 1, 0)
                      WHERE event_id = %d; ''' % (winning_entity, event_id))

          cur.execute(''' UPDATE PLAYERS
                      INNER JOIN PICKS ON PLAYERS.id = PICKS.player_id
                      SET PLAYERS.coins = IF(PICKS.picked_entity = %d, PLAYERS.coins + PICKS.correct_payout, PLAYERS.COINS)
                      WHERE PICKS.event_id = %d; ''' % (winning_entity, event_id))
          conn.commit()

          message = {'status': POST_SUCCESSFUL, 'message': 'The broadcast of the event was successful'}

      except Exception as e:
          logging.error('DB exception: %s' % e)
          message = {'status': DB_EXCEPTION_THROWN, 'message': 'The creation of the new player failed. DB exception: %s' % e}
      
      cur.close()
      conn.close()
      return jsonify(message)




  @app.route('/players/<int:player_id>/events/current', methods =['GET'])
  def get_current_events(player_id):
      conn = creatConnection()
      cur = conn.cursor()
      cmd_str = '''  SELECT e.id as event_id, e.event_title, c.name as category_name,
          TIMESTAMPDIFF(SECOND, UTC_TIMESTAMP(), e.event_time) AS expires_in,
          entity1_id, one.name as entity1_name, entity2_id, two.name as entity2_name,
          event_time, e.entity1_pool, e.entity2_pool FROM EVENTS AS e
          JOIN ENTITIES AS one ON e.entity1_id = one.id
          JOIN ENTITIES AS two ON e.entity2_id = two.id
          LEFT JOIN PICKS ON (e.id = PICKS.event_id AND PICKS.player_id = %s)
          #JOIN PLAYERS ON (PLAYERS.api_key = s)
          JOIN CATEGORIES as c ON e.category_id = c.id
          WHERE PICKS.event_id IS NULL AND picking_active = 1; '''
      cur.execute(cmd_str, (player_id))
      #cur.execute(''' SELECT EVENTS.id, entity1_id, entity2_id, category_id, event_time,
       #   EVENTS.entity1_pool, EVENTS.entity2_pool, active FROM EVENTS
        #  LEFT JOIN PICKS ON (EVENTS.id = PICKS.event_id AND PICKS.player_id = %d)
         # WHERE PICKS.event_id IS NULL; ''' % (player_id))

      rv = cur.fetchall()

      return jsonify(rv)


  @app.route('/players', methods=['POST'])
  def create_player():
      conn = creatConnection()
      cur = conn.cursor()
      print ("Trying to create player")

      ret_username_exists = username_or_email_exists_helper(request.json['username'])
      ret_email_exists = username_or_email_exists_helper(request.json['email'])

      field_taken = not (ret_username_exists['status'] == USERNAME_INVALID and 
                            ret_email_exists['status'] == USERNAME_INVALID)


      if (not field_taken):
          try:
              #salt = os.urandom(16)
              #n_iter = os.urandom(2)
              #while (int.from_bytes(n_iter, 'big') * 4 < 100000):
                #print (n_iter)
                #n_iter = os.urandom(2)
              #print (int.from_bytes(n_iter, 'big') * 4)
              #int_iter = int.from_bytes(n_iter, 'big') * 4
              #iter_bytes = int_iter.to_bytes(3, byteorder='big')
              #salted = salt[0: 8] + iter_bytes + salt[8:]
              #salted_db = binascii.hexlify(salted).decode("utf-8")
              #ph = PasswordHasher()
              #hash = ph.hash(request.json['password'])
              #hashed_pw = bcrypt.hashpw(bytes(request.json['password'], encoding='utf-8'), bcrypt.gensalt())
              bytes_pass = bytes(request.json['password'], encoding='utf-8')
              hashed_pw = bcrypt.hashpw(bytes_pass, bcrypt.gensalt())



              #hashed_pw = hashlib.pbkdf2_hmac('sha256', bytes(request.json['password'], encoding='utf-8'), salt, int_iter)
              hashed_pw_db = binascii.hexlify(hashed_pw).decode("utf-8")
              #print (hashed_pw_db)

              api_key = binascii.hexlify(os.urandom(API_KEY_LENGTH)).decode('utf-8')

              cmd_str = '''INSERT INTO PLAYERS (FIRSTNAME, LASTNAME, USERNAME, PASSWORD, SALTED'''
              #if (request.json['email'] != None):


              cmd_str += ''',
                          EMAIL, PHONE, BIRTHDATE, COINS, API_KEY)# COLLEGE_ID, COMPANY_ID, COINS) 
                          VALUES(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s) '''

              cur.execute(cmd_str, (request.json['firstName'],request.json['lastName'],request.json['username'],
                              hashed_pw_db, 'salted_db', request.json['email'],request.json['phone'],
                              request.json['birthDate'], NO_INITIAL_COINS, api_key))#request.json['college_id'], request.json['company_id'], NO_INITIAL_COINS))

              # report back the id of the new player that was just added for integration testing purposes
              if app.config['TESTING']:
                cur.fetchall()
                cur.execute('''SELECT Auto_increment FROM information_schema.tables WHERE table_name='PLAYERS' AND table_schema = DATABASE();''')
                rv = cur.fetchone()

              conn.commit()
              if app.config['TESTING']:
                message = {'status': POST_SUCCESSFUL, 'message': 'New player record is created succesfully', 'api_key' : api_key, 'new_id': int(rv['Auto_increment']) - 1}
              else:
                message = {'status': POST_SUCCESSFUL, 'message': 'New player record is created succesfully', 'api_key' : api_key}
              cur.close()
          except Exception as e:
              #logging.error('DB exception: %s' % e)
              exc_type, exc_obj, exc_tb = sys.exc_info()
              fname = os.path.split(exc_tb.tb_frame.f_code.co_filename)[1]
              logging.error(exc_type, fname, exc_tb.tb_lineno)
              message = {'status': DB_EXCEPTION_THROWN, 'message': 'The creation of the new player failed. DB exception: %s' % e}
      
      else:

          if (ret_email_exists['status'] == USERNAME_VALID):
              message = {'status': EMAIL_EXISTS, 'message': 'Email already exists'}

          if (ret_username_exists['status'] == USERNAME_VALID):
              message = {'status': USERNAME_EXISTS, 'message': 'Username already exists'}


      conn.close()

      return jsonify(message)

  @app.route('/players/leaderboard/all', methods=['GET'])
  def get_leaderboard_all():
      conn = creatConnection()
      cur = conn.cursor()
      cur.execute(''' SELECT *
                      FROM PLAYERS ORDER BY coins DESC LIMIT %d; ''' % (NUM_LEADERBOARD_ALL))
      #cur.execute(''' SELECT EVENTS.id, entity1_id, entity2_id, category_id, event_time,
       #   EVENTS.entity1_pool, EVENTS.entity2_pool, active FROM EVENTS
        #  LEFT JOIN PICKS ON (EVENTS.id = PICKS.event_id AND PICKS.player_id = %d)
         # WHERE PICKS.event_id IS NULL; ''' % (player_id))

      rv = cur.fetchall()
      return jsonify(rv)


  @app.route('/players/username_exists', methods=['POST'])
  def username_exists():
      return jsonify(username_or_email_exists_helper(request.json['username']))

  def username_or_email_exists_helper(username):
      conn = creatConnection()
      cur = conn.cursor()
      try:
          if '@' in username:
              cur.execute('''SELECT id FROM PLAYERS WHERE email='%s'; '''%(username));#%(username));
          else:
              cur.execute('''SELECT id FROM PLAYERS WHERE username='%s'; '''%(username));#%(username));
      
          rv = cur.fetchone()
          if rv is None:
              message = {'status': USERNAME_INVALID, 'message': 'No matching username/email found'}
          else:
              message = {'status': USERNAME_VALID, 'message': 'Matching username/email found', 'id': rv['id']}

      except Exception as e:
          logging.error('DB exception: %s' % e)
          message = {'status': DB_EXCEPTION_THROWN, 'message': 'DB Exception thrown'}

      cur.close()
      conn.close()
      return message


  @app.route('/players/<int:player_id>/login', methods=['POST'])
  def loginPlayer(player_id):
      conn = creatConnection()
      cur = conn.cursor()
      password = request.json['password']
      #print("Reached login endpoint with username %s and password %s"%( username, password))
      try:

          cur.execute('''SELECT password, salted, api_key FROM PLAYERS WHERE id=%d; '''%(player_id));#%(username));
          print("Reached post query")
          rv = cur.fetchone()
          if rv is None:
              message = {'status': USERNAME_INVALID, 'message': 'No matching username/email found'}
              return jsonify(message)
          #print("returned value's password is "+rv['password'])

          #salted_db = rv['salted']
          hashed_pw_db = rv['password']
          #salted_combo = binascii.unhexlify(salted_db.encode('utf-8'))

          hashed_pw = binascii.unhexlify(hashed_pw_db.encode('utf-8'))
          pw_correct = bcrypt.checkpw(bytes(password, encoding = 'utf-8'), hashed_pw)

          #salt = salted_combo[0:8] + salted_combo[11:]
          #int_iter = int.from_bytes(salted_combo[8:11], 'big')
          #entered_pw_hashed = hashlib.pbkdf2_hmac('sha256', bytes(password, encoding = 'utf-8'), salt, int_iter)
          #pw_correct = (entered_pw_hashed == binascii.unhexlify(hashed_pw_db.encode('utf-8')))
          #print("The entered password hashed is "+binascii.hexlify(entered_pw_hashed).decode('utf-8'))
          print ("The password's truth is "+str(pw_correct))
          if pw_correct:
              message = {'status': PASSWORD_CORRECT, 'message': 'The password is correct.', 'api_key': rv['api_key']}
          else:
              message = {'status': PASSWORD_INCORRECT, 'message': 'The password is incorrect.'}

      except Exception as e:
          logging.error('DB exception: %s' % e)
          message = {'status': DB_EXCEPTION_THROWN, 'message': 'DB Exception thrown.: %s'}

      cur.close()
      conn.close()

      return jsonify(message)

  @app.route('/players/<int:player_id>', methods=['PUT'])
  def update_player(player_id):
      conn = creatConnection()
      cur = conn.cursor()
      try:
          # Since all fields are specified here, an update either needs to contain all the previous information of unchanged fields in the request or
          # generate a MYSQL command that only updates new fields
          cur.execute('''UPDATE PLAYERS SET FIRSTNAME='%s', LASTNAME='%s', PASSWORD='%s', EMAIL='%s', PHONE='%s', BIRTHDATE='%s' 
                     WHERE ID=%s '''%(request.json['firstName'],request.json['lastName'], request.json['password'],
                     request.json['email'],request.json['phone'],request.json['birthDate'],player_id)) # request.json['college'],request.json['company']
          conn.commit()
          message = {'status': PUT_SUCCESSFUL, 'message': 'The player record is updated succesfully'}
          cur.close()  
      except Exception as e:
          logging.error('DB exception: %s' % e)   
          message = {'status': DB_EXCEPTION_THROWN, 'message': 'Player update failed.'}
      conn.close()
      return jsonify(message)

  @app.route('/players/<int:player_id>', methods=['DELETE'])
  def delete_player(player_id):
      conn = creatConnection()
      cur = conn.cursor()
      try:
          cur.execute('''DELETE FROM PLAYERS WHERE ID=%s '''%(player_id))    
          message = {'status': DELETE_SUCCESSFUL, 'message': 'The player record is deleted succesfully'}
          conn.commit()
          cur.close()  
      except Exception as e:
          logging.error('DB exception: %s' % e)   
          message = {'status': DB_EXCEPTION_THROWN, 'message': 'Player delete failed.'}
      conn.close()
      return jsonify(message)

  return app
