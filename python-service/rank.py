import pymysql
import numpy as np
import math

def creatConnection():
    connectString = '129.150.120.63:/mydatabase'
    hostname = connectString[:connectString.index(":")]
    database = connectString[connectString.index("/")+1:]
    user='root'
    passwd = 'lynx1N{}'
    conn = pymysql.connect(host=hostname, 
                           #port=port,
                           user=user, 
                           passwd=passwd,
                           db=database,
                           cursorclass=pymysql.cursors.DictCursor)
    return conn;


conn = creatConnection()
cur = conn.cursor()

cur.execute('''SELECT MAX(id) AS max FROM PLAYERS''')

max = cur.fetchone()['max']
print (max)#(len(result))

PLAYERS_AT_ONCE = 10

i = 0
while (i < max):
    cur_string = '''SELECT TIMESTAMPDIFF(DAY, pick_timestamp, UTC_TIMESTAMP())
    AS days, player_id, pick_correct, correct_payout, bet_size
    FROM PICKS WHERE pick_correct IS NOT NULL AND
    TIMESTAMPDIFF(DAY, pick_timestamp, UTC_TIMESTAMP()) < 365 AND player_id in ('''
    for j in range(1, min(PLAYERS_AT_ONCE + 1, max - i + 1)):
        if (j < min(PLAYERS_AT_ONCE, max - i) ):
            cur_string += str(i+j) + ", "
        else:
            cur_string += str(i+j) + ");"
    print (cur_string)
    cur.execute(cur_string)
    rv = cur.fetchall()
    if rv is None:
        continue
    scores = np.zeros((min(PLAYERS_AT_ONCE, max - i), 3))

    #print (len(rv))
    for j in range(0, len(rv)):
        pick = rv[j]
        #print (pick)
        time_factor = float(365 - pick['days']) / 100.0
        pick_factor = 0.0
        if (pick['pick_correct']):
            pick_factor = float(pick['correct_payout'])
        else:
            chance_other_win = 1.0 - (float(pick['bet_size']) / float(pick['correct_payout']))
            pick_factor = (float(pick['correct_payout']) / chance_other_win) * -1.0

        pick_factor /= 100.0
        #print(pick_factor, time_factor)
        scores[pick['player_id'] % PLAYERS_AT_ONCE - 1][0] += pick_factor * time_factor

        #print(score)
        scores[pick['player_id'] % PLAYERS_AT_ONCE - 1][1] += 1
        #print(scores)

    #print(scores)
    for j in range(0, min(PLAYERS_AT_ONCE, max - i)):
        freq_factor = math.log(scores[j][1], 10) if scores[j][1] > 0 else 0
        if (scores[j][0] < 0 and freq_factor != 0):
            freq_factor = 1.0 / freq_factor
        scores[j][2] = scores[j][0] * freq_factor
        i += 1
    print (scores)

cur.close()
conn.close()