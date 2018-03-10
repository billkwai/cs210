#!/usr/bin/env python
from __future__ import print_function
from flask import Flask, jsonify, abort, request
from flask_cors import CORS, cross_origin

#import mysql.connector
#from mysql.connector import errorcode

import logging
import pymysql
import os
import hashlib, binascii, base64
#import bcrypt
#from argon2 import PasswordHasher
#import bcrypt

app = Flask(__name__)
CORS(app)
cors = CORS(app, resources={r"/api/*": {"origins": "*","methods":"POST,DELETE,PUT,GET,OPTIONS"}})

NO_INITIAL_COINS = 2500
USERNAME_INVALID = -1
USERNAME_VALID = 1
PASSWORD_INCORRECT = -2
PASSWORD_CORRECT = 1
DB_EXCEPTION_THROWN = -3

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
    connectString = os.environ.get('MYSQLCS_CONNECT_STRING', '129.150.120.63:/mydatabase')
    #connectString = os.environ.get('MYSQLCS_CONNECT_STRING', 'localhost:/users')
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
                  email VARCHAR(255) NOT NULL,
                  phone VARCHAR(255) NOT NULL,
                  birthdate VARCHAR(10) NOT NULL,
                  college_id INT,
                  company_id INT,
                  coins INTEGER NOT NULL,
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
                  entity1_id INTEGER NOT NULL,
                  entity2_id INTEGER NOT NULL,
                  category_id INTEGER NOT NULL,
                  event_time TIMESTAMP NOT NULL,
                  entity1_pool INTEGER NOT NULL,
                  entity2_pool INTEGER NOT NULL,
                  active  BOOL NOT NULL,
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
                  picked_entity1 BOOL NOT NULL,
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
    cur.execute('''SELECT * FROM PLAYERS WHERE ID = %s'''%(player_id))
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


@app.route('/players/<int:player_id>/picks', methods=['POST'])
def make_pick(player_id):
    conn = creatConnection()
    cur = conn.cursor()
    try:
        entity1_pool = request.json['entity1_pool']
        entity2_pool = request.json['entity2_pool']
        bet_size = request.json['bet_size']
        payout = (float(entity1_pool + entity2_pool) / float(entity1_pool)) * bet_size
        cur.execute('''INSERT INTO PICKS (player_id, event_id, picked_entity1, entity1_pool, entity2_pool, correct_payout, bet_size, pick_timestamp)
                    VALUES(%d, %d, %d, %d, %d, %f, %d, UTC_TIMESTAMP()) '''%(player_id, request.json['event_id'], request.json['picked_entity1'],
                      entity1_pool, entity2_pool, payout, bet_size))
        conn.commit()
        message = {'status': 'The pick record was created succesfully'}
    except Exception as e:
        logging.error('DB exception: %s' % e)   
        message = {'status': 'Pick creation failed.'}

    cur.close()
    conn.close()
    return jsonify(message)


@app.route('/players/<int:player_id>/picks/live', methods =['GET'])
def get_past_events(player_id):
    conn = creatConnection()
    cur = conn.cursor()
    cur.execute(''' SELECT one.id AS entity1_id, one.name as entity1_name, two.id AS entity2_id,
      two.name as entity2_name, p.pick_timestamp, p.picked_entity1, p.entity1_pool, p.entity2_pool,p.correct_payout
      FROM EVENTS AS e JOIN ENTITIES AS one ON e.entity1_id = one.id JOIN ENTITIES AS two ON e.entity2_id = two.id
      JOIN PICKS AS p ON e.id = p.event_id WHERE player_id = %d AND active = 1
      ORDER BY pick_timestamp DESC; ''' % (player_id))
    #cur.execute(''' SELECT EVENTS.id, entity1_id, entity2_id, category_id, event_time,
     #   EVENTS.entity1_pool, EVENTS.entity2_pool, active FROM EVENTS
      #  LEFT JOIN PICKS ON (EVENTS.id = PICKS.event_id AND PICKS.player_id = %d)
       # WHERE PICKS.event_id IS NULL; ''' % (player_id))

    rv = cur.fetchall()
    return jsonify(rv)


@app.route('/players/<int:player_id>/events/current', methods =['GET'])
def get_current_events(player_id):
    conn = creatConnection()
    cur = conn.cursor()
    cur.execute('''  SELECT entity1_id, one.name as entity1_name, entity2_id, two.name as entity2_name,
        event_time, e.entity1_pool, e.entity2_pool FROM EVENTS AS e
        JOIN ENTITIES AS one ON e.entity1_id = one.id
        JOIN ENTITIES AS two ON e.entity2_id = two.id
        LEFT JOIN PICKS ON (e.id = PICKS.event_id AND PICKS.player_id = %d)
        WHERE PICKS.event_id IS NULL AND active = 1; ''' % (player_id))
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
    try:
        salt = os.urandom(16)
        n_iter = os.urandom(2)
        while (int.from_bytes(n_iter, 'big') * 4 < 100000):
          #print (n_iter)
          n_iter = os.urandom(2)
        #print (int.from_bytes(n_iter, 'big') * 4)
        int_iter = int.from_bytes(n_iter, 'big') * 4
        iter_bytes = int_iter.to_bytes(3, byteorder='big')
        salted = salt[0: 8] + iter_bytes + salt[8:]
        salted_db = binascii.hexlify(salted).decode("utf-8")
        #ph = PasswordHasher()
        #hash = ph.hash(request.json['password'])
        #hashed_pw = bcrypt.hashpw(bytes(request.json['password'], encoding='utf-8'), bcrypt.gensalt())
        hashed_pw = hashlib.pbkdf2_hmac('sha256', bytes(request.json['password'], encoding='utf-8'), salt, int_iter)
        hashed_pw_db = binascii.hexlify(hashed_pw).decode("utf-8")
        print (hashed_pw_db)
        cur.execute('''INSERT INTO PLAYERS (FIRSTNAME, LASTNAME, USERNAME, PASSWORD, SALTED, EMAIL, PHONE, BIRTHDATE, COINS)# COLLEGE_ID, COMPANY_ID, COINS) 
                    VALUES('%s','%s', '%s', '%s','%s','%s','%s','%s', '%d') '''%(request.json['firstName'],request.json['lastName'],request.json['username'],
                        hashed_pw_db, salted_db, #hash, 
                    request.json['email'],request.json['phone'],request.json['birthDate'], NO_INITIAL_COINS))#request.json['college_id'], request.json['company_id'], NO_INITIAL_COINS))    
        conn.commit()
        message = {'status': 'New player record is created succesfully'}
        cur.close()  
    except Exception as e:
        logging.error('DB exception: %s' % e)
        message = {'status': 'The creation of the new player failed. DB exception: %s' % e}
    conn.close()
    return jsonify(message)

@app.route('/players/username_exists', methods=['GET'])
def username_exists():
    conn = creatConnection()
    cur = conn.cursor()
    username = request.args.get('username')
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
    return jsonify(message)

@app.route('/players/<int:player_id>/login', methods=['GET'])
def loginPlayer(player_id):
    conn = creatConnection()
    cur = conn.cursor()
    password = request.args.get('password')
    #print("Reached login endpoint with username %s and password %s"%( username, password))
    try:

        cur.execute('''SELECT password, salted FROM PLAYERS WHERE id=%d; '''%(player_id));#%(username));
        print("Reached post query")
        rv = cur.fetchone()
        if rv is None:
            message = {'status': USERNAME_INVALID, 'message': 'No matching username/email found'}
            return jsonify(message)
        #print("returned value's password is "+rv['password'])

        salted_db = rv['salted']
        hashed_pw_db = rv['password']
        salted_combo = binascii.unhexlify(salted_db.encode('utf-8'))
        salt = salted_combo[0:8] + salted_combo[11:]
        int_iter = int.from_bytes(salted_combo[8:11], 'big')
        entered_pw_hashed = hashlib.pbkdf2_hmac('sha256', bytes(password, encoding = 'utf-8'), salt, int_iter)
        pw_correct = (entered_pw_hashed == binascii.unhexlify(hashed_pw_db.encode('utf-8')))
        #print("The entered password hashed is "+binascii.hexlify(entered_pw_hashed).decode('utf-8'))
        print ("The password's truth is "+str(pw_correct))
        if pw_correct:
            message = {'status': PASSWORD_CORRECT, 'message': 'The password is correct.'}
        else:
            message = {'status': PASSWORD_INCORRECT, 'message': 'The password is incorrect.'}

    except Exception as e:
        logging.error('DB exception: %s' % e)
        message = {'status': DB_EXCEPTION_THROWN, 'message': 'DB Exception thrown.'}

    cur.close()
    conn.close()

    return jsonify(message)

@app.route('/players/<int:player_id>', methods=['PUT'])
def update_player(player_id):
    conn = creatConnection()
    cur = conn.cursor()
    try:
        cur.execute('''UPDATE PLAYERS SET FIRSTNAME='%s', LASTNAME='%s', PASSWORD='%s', EMAIL='%s', PHONE='%s', BIRTHDATE='%s', COLLEGE='%s', COMPANY='%s' 
                   WHERE ID=%s '''%(request.json['firstName'],request.json['lastName'], request.json['password'],
                   request.json['email'],request.json['phone'],request.json['birthDate'],request.json['college'],request.json['company'],player_id))    
        conn.commit()
        message = {'status': 'The player record is updated succesfully'}
        cur.close()  
    except Exception as e:
        logging.error('DB exception: %s' % e)   
        message = {'status': 'Player update failed.'}
    conn.close()
    return jsonify(message)

@app.route('/players/<int:player_id>', methods=['DELETE'])
def delete_player(player_id):
    conn = creatConnection()
    cur = conn.cursor()
    try:
        cur.execute('''DELETE FROM PLAYERS WHERE ID=%s '''%(player_id))    
        message = {'status': 'The player record is deleted succesfully'}
        conn.commit()
        cur.close()  
    except Exception as e:
        logging.error('DB exception: %s' % e)   
        message = {'status': 'Player delete failed.'}
    conn.close()
    return jsonify(message)

if __name__ == '__main__':
      app.run(host='0.0.0.0', port=int(os.environ.get('PORT', '8080')))
