import pymysql
import numpy as np
import math
import sys
from pympler import asizeof

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
#print (max)#(len(result))

PLAYERS_AT_ONCE_PICKS = 100000
PLAYERS_AT_ONCE_PERCENTILE = 1000

i = 0
while (i < max):
    cur_string = '''SELECT TIMESTAMPDIFF(DAY, pick_timestamp, UTC_TIMESTAMP())
    AS days, player_id, pick_correct, correct_payout, bet_size
    FROM PICKS WHERE pick_correct IS NOT NULL AND
    TIMESTAMPDIFF(DAY, pick_timestamp, UTC_TIMESTAMP()) < 365 AND player_id in ('''
    for j in range(1, min(PLAYERS_AT_ONCE_PICKS + 1, max - i + 1)):
        if (j < min(PLAYERS_AT_ONCE_PICKS, max - i) ):
            cur_string += str(i+j) + ", "
        else:
            cur_string += str(i+j) + ");"
    #print (cur_string)
    cur.execute(cur_string)
    rv = cur.fetchall()
    if rv is None:
        continue
    scores = np.zeros((min(PLAYERS_AT_ONCE_PICKS, max - i), 3))

    #print (len(rv))
    print(asizeof.asizeof(rv))
    #   print(rv[2])
    for j in range(0, len(rv)):
        pick = rv[j]
        #if (pick['player_id'] == 67):
            #print(pick['days'])
        #print (pick)
        time_factor = float(365 - pick['days']) / 100.0
        pick_factor = 0.0
        if (pick['pick_correct']):
            pick_factor = float(pick['correct_payout'])
        else:
            chance_other_win = 1.0 - (float(pick['bet_size']) / float(pick['correct_payout']))
            pick_factor = (float(pick['bet_size']) / chance_other_win) * -1.0

        pick_factor /= 100.0
        #if (pick['player_id'] == 67):
            #print(pick_factor, time_factor)
        scores[pick['player_id'] % PLAYERS_AT_ONCE_PICKS - 1][0] += pick_factor * time_factor

        #print(score)
        scores[pick['player_id'] % PLAYERS_AT_ONCE_PICKS - 1][1] += 1
        #print(scores)

    #print(scores)
    for j in range(0, min(PLAYERS_AT_ONCE_PICKS, max - i)):
        freq_factor = math.log(scores[j][1], 10) if scores[j][1] > 0 else 0
        if (scores[j][0] < 0 and freq_factor != 0):
            freq_factor = 1.0 / freq_factor
        scores[j][2] = scores[j][0] * freq_factor

    #print (scores)
    if (np.sum(scores, axis=0)[1] != 0):
        
        update_str = '''UPDATE PLAYERS SET score = (CASE id'''
        second_part_str = ""

        for j in range(0, min(PLAYERS_AT_ONCE_PICKS, max - i)):
            if (scores[j][1] != 0):
                update_str += " WHEN " + str(j + 1 + i) + " THEN " + str(scores[j][2])
                second_part_str += str(j + 1 + i) + ", "

        update_str += ' END) WHERE id IN ('
        second_part_str = second_part_str[0:len(second_part_str)-2]

        update_str = update_str + second_part_str
        update_str += ");"

        cur.execute(update_str)
        conn.commit()
        #print(update_str)

    i += min(PLAYERS_AT_ONCE_PICKS, max - i)


cur.execute('SELECT COUNT(score) AS count FROM PLAYERS WHERE score != 0;')
rv = cur.fetchone()
if rv != None:
    count = rv['count']
    index = 0
    while (index < count):
        cur.execute('''SELECT score, id FROM PLAYERS WHERE score != 0 ORDER BY score LIMIT %s, %s;''',
            (index, PLAYERS_AT_ONCE_PERCENTILE))
        rv = cur.fetchall()
        #if (index == 10):
            #print(rv)

        percentiles = np.zeros((len(rv), 2))
        for i in range(0, len(rv)):
            player = rv[i]

            percentile = 100 * (float(index) / float(count - 1))

            if (percentile < 1):
                percentile = 1.0

            percentiles[i][0] = percentile
            percentiles[i][1] = player['id']
            index += 1
        #print(percentiles)

        update_str = '''UPDATE PLAYERS SET percentile = (CASE id'''
        second_part_str = ""

        for i in range(0, len(rv)):
                update_str += " WHEN " + str(int(percentiles[i][1])) + " THEN " + str(percentiles[i][0])
                second_part_str += str(int(percentiles[i][1])) + ", "

        update_str += ' END) WHERE id IN ('
        second_part_str = second_part_str[0:len(second_part_str)-2]

        update_str = update_str + second_part_str
        update_str += ");"

        cur.execute(update_str)
        conn.commit()
        
    #print(count)


cur.close()
conn.close()