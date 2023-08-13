# server
import socket as sock
import threading
import struct

# database
import sqlite3 as sqlite
import json
import hashlib
import jwt

# other
import random
import os
import datetime
import colors

# classification
from classifier import Classifier
from logger import Log
# dir change
try:
    os.chdir("./Server/")
except:
    pass

# Logger

# NOTE Logger testing
# Log("Message", "msg")
# Log("Error", "err")
# Log("Warn", "warn")
# Log("Debug", "wmsg")

# database create
Log("Loading database")
DATABASE = sqlite.connect(r"./database/main.bd", check_same_thread=False)

# Creating table "users"
CURSOR = DATABASE.cursor()
CURSOR.execute("""CREATE TABLE IF NOT EXISTS users(
   userid INTEGER PRIMARY KEY,
   email TEXT,
   name TEXT,
   password TEXT,
   subscribedto TEXT,
   jwtcode TEXT);
""")
DATABASE.commit()


# Create server
Log("Loading server")
SERVER = sock.create_server(("", 2020), family=sock.AF_INET)
SERVER.listen()
isRunning = True


"""
REQUEST TYPES

0 - LOGIN USER
DATA: REQTYPE(4):JSONLEN(4):JSON

1 - CREATE USER
DATA: REQTYPE(4):JSONLEN(4):JSON

2 - LOGIN WITH JWT
DATA: REQTYPE(4):JWTLEN(4):JWT

3 - PROCESS DATA
DATA: REQTYPE(4):JSONLEN(4):JSON
"""

# request handler
def random_key(length):
    number = '0123456789'
    alpha = 'abcdefghijklmnopqrstuvwxyz'
    id = ''
    for i in range(0,length,2):
        id += random.choice(number)
        id += random.choice(alpha)
    return id

def handle(s, ip):
    Log("Handling request", "wmsg")

    try:
        req_type = s.recv(4)
        req_type = struct.unpack(">I", req_type)[0]
        
        Log(f"Reqest type: {req_type}", "wmsg")

        if req_type == 0:
            data_len = s.recv(4)
            data_len = struct.unpack(">I", data_len)[0]

            data = s.recv(data_len)
            data = json.loads(data.decode("utf-8"))

            Log("Executing", "wmsg")
            CURSOR.execute(f'SELECT * FROM users WHERE email="{data["email"].lower()}"')
            Log("Fetching", "wmsg")
            uid, email, name, password, subscribedto, jwtcode = CURSOR.fetchall()[0]
            Log("Checking", "wmsg")
            if data["password"] == password:
                Log("User Logged in", "wmsg")
                
                answ = jwt.encode({"username":email.lower()}, jwtcode)
                answ = answ.encode()

                l = len(answ)

                j = json.dumps({"name": name, "subto": subscribedto})
                j = j.encode()
                lj = len(j)

                Log("Successful log in by password")
                s.send("ok|".encode()+answ+"|".encode()+j)
            else:
                Log("User tried to Log in. Uncorrect password", "warn")
                s.send("uncorrect password")
        elif req_type == 1:
            data_len = s.recv(4)
            data_len = struct.unpack(">I", data_len)[0]

            Log("Received data length "+str(data_len), "wmsg")

            data = s.recv(data_len)[1::].decode("utf-8")
            Log(data, "wmsg")

            try:
                data = json.loads(data)
            except:
                data = json.loads("{"+data)

            Log("Checking is user exists", "wmsg")

            CURSOR.execute(f'SELECT * FROM users WHERE email="{data["email"].lower()}"')
            users = CURSOR.fetchall()

            Log(f"Users: {users}", "wmsg")
            
            if len(users) == 0:
                key = random_key(16)

                jwt_s = jwt.encode({"username":data["email"].lower()}, key, algorithm="HS256")
                jwt_s = str(jwt_s).encode()

                user = (None, data["email"].lower(), data["name"], data["password"], "notsub", key)
                CURSOR.execute("INSERT INTO users VALUES(?, ?, ?, ?, ?, ?);", user)
                DATABASE.commit()

                l = len(jwt_s)
                
                j = json.dumps({"name": data["name"], "subto": "notsub"}).encode()

                Log(f"User {data['email'].lower()} created", "msg")

                s.send("ok|".encode()+jwt_s+"|".encode()+j)
            else:
                Log(f"User {data['email'].lower()} already exists", "warn")
                d = "User already exists.".encode()
                s.send(d)
        elif req_type == 2:
            Log("Receiving data length", "wmsg")
            data_len = s.recv(4)
            data_len = struct.unpack(">I", data_len)[0]

            Log("Receiving data", "wmsg")
            data = s.recv(data_len)
            data = data.decode("utf-8")

            Log("Spliting", "wmsg")
            username, jwt_s = data.split("|")

            try:
                Log("Username: "+ username)
                CURSOR.execute(f'SELECT * FROM users WHERE email="{username}"')

                uid, email, name, password, subscribedto, jwtcode = CURSOR.fetchall()[0]
            except:
                Log("User is not exists")
                data = "User is not exists".encode()
                s.send(data)

            try:
                dec = jwt.decode(jwt_s, jwtcode, algorithms=["HS256"])
                if dec["username"] == email:
                    j = json.dumps({"name": name, "subto": subscribedto})
                    j = j.encode()

                    l = len(j)

                    s.send(j)
                else:
                    raise ValueError("JWT username is not matching")

                Log("Successful log in by JWT")
            except Exception as e:
                Log("Error while logging in by JWT: "+str(e), "err")
                data = str(e).encode()
                s.send(data)
        elif req_type == 3:
            jl = s.recv(4)
            jl = struct.unpack(">I", jl)[0]

            j = s.recv(jl)
            j = j.decode("utf-8")

            js = json.loads(j)

            CURSOR.execute(f'SELECT * FROM users WHERE email="{js["username"].lower()}"')
            if len(CURSOR.fetchall()) > 0:
                data = json.dumps({"pleasure": Classifier().pleasure_process_data(js["acts"], js["days"], js["humans"], js["cost"]), 
                                   "cost": Classifier().cost_process_data(js["acts"], js["days"], js["humans"], js["cost"])})
                Log(data, "wmsg")
                data = data.encode()

                s.send(data)
            else:
                s.send("User not exists")
        else:
            s.send("403 Not implemented")
    except Exception as e:
        s.send("not".encode())
        Log("Error in request handle. "+repr(e), "err")

# mainloop
Log("Running server")
while isRunning:
    try:
        conn, ip = SERVER.accept()
        threading.Thread(target=handle, args=(conn, ip)).start()
        Log("Thread started. Request handling", "wmsg")
    except Exception as e:
        Log("Exception in mainloop: "+str(e), "err")