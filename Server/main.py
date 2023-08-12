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

# dir change
try:
    os.chdir("./Server/")
except:
    pass

# logger
loglevels: dict[str:int] = {
    "DEBUG": 0,
    "MESSAGE": 9,
    "WARN": 19,
    "ERROR": 29,
    "NONE": 30
}

min_log_level:int = 0
def log(msg, level="msg"):
    msg:str = "["+str(datetime.datetime.now())+"] ["+("INFO" if level == "msg" else "ERROR" if level == "err" else "WARN" if level == "warn" else "DEBUG" if level == "wmsg" else "INFO")+"] "+msg

    if level=="msg":
        msg = colors.color(msg, "rgb(0, 250, 20)")
    elif level=="err":
        msg = colors.color(msg, "rgb(250, 10, 10)")
    elif level=="warn":
        msg = colors.color(msg, "rgb(250, 250, 10)")
    elif level=="wmsg":
        msg = colors.color(msg, "rgb(0, 0, 255)")

    if min_log_level > 0:
        if level!="wmsg":
            if min_log_level < 10 and level == "msg":
              print(msg)
            elif min_log_level < 20 and level == "warn":
                print(msg)
            elif min_log_level < 30 and level == "err":
                print(msg)  
    else:
        print(msg)

# NOTE logger testing
# log("Message", "msg")
# log("Error", "err")
# log("Warn", "warn")
# log("Debug", "wmsg")

# database create
log("Loading database")
DATABASE = sqlite.connect(r"./database/main.bd")

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
log("Loading server")
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
    log("Handling request", "wmsg")

    try:
        req_type = s.recv(4)
        req_type = struct.unpack(">I", req_type)


        if req_type == 0:
            data_len = s.recv(4)
            data_len = struct.unpack(">I", data_len)

            data = s.recv(data_len)
            data = json.loads(data.decode("utf-8"))

            CURSOR.execute(f"SELECT * FROM users WHERE email={data['email']}")
            uid, email, name, password, subscribedto, jwtcode = CURSOR.fetchone()[0]

            if data["password"] == password:
                log("User logged in", "wmsg")
                
                answ = json.dumps(jwt.encode({"username":email, "password":password}, jwtcode))
                answ = answ.encode()

                l = len(answ)

                j = json.dumps({"name": name, "subto": subscribedto})
                j = j.encode()
                lj = len(j)

                s.send(struct.pack(">I", 1)+struct.pack(">I", l)+answ+struct.pack(">I", lj)+j)
                # NOTE FORMAT: CODE(4):JWTLEN(4):JWT:JSONLEN(4):JSON
            else:
                log("User tried to log in. Uncorrect password", "warn")
                s.send(struct.pack(">I", 0))
        elif req_type == 1:
            data_len = s.recv(4)
            data_len = struct.unpack(">I", data_len)

            data = s.recv(data_len)
            data = json.loads(data.decode("utf-8"))

            CURSOR.execute(f"SELECT * FROM users WHERE email={data['email']}")
            users = CURSOR.fetchall()

            if len(users) == 0:
                key = random_key(16)

                jwt_s = jwt.encode({"username":data["email"]}, key)
                jwt_s = str(jwt_s).encode()

                user = (data["email"], data["name"], data["password"], "notsub", key)
                CURSOR.execute("INSERT INTO users VALUES(?, ?, ?, ?, ?);", user)

                l = len(jwt_s)

                s.send(struct.pack(">I", 1)+struct.pack(">I", l)+jwt_s)
                # NOTE FORMAT: CODE(4):JWTLEN(4):JWT
            else:
                s.send(struct.pack(">I", 0))
        elif req_type == 2:
            data_len = s.recv(4)
            data_len = struct.unpack(">I", data_len)

            data = s.recv(data_len)
            data = data.decode("utf-8")

            username, jwt_s = data.split("|")

            CURSOR.execute(f"SELECT * FROM users WHERE email={username}")
            uid, email, name, password, subscribedto, jwtcode = CURSOR.fetchone()[0]

            try:
                dec = jwt.decode(jwt_s, jwtcode)
                if dec["password"] == password:
                    j = json.dumps({"name": name, "subto": subscribedto})
                    j = j.encode()
                    l = len(j)

                    s.send(struct.pack(">I", 1)+struct.pack(">I", l)+j)
                    # NOTE FORMAT: CODE(4):JSONLEN(4):JSON
            except:
                s.send(struct.pack(">I", 0))
        elif req_type == 3:
            jl = s.recv(4)
            jl = struct.unpack(">I", jl)

            j = s.recv(jl)
            j = j.decode("utf-8")

            js = json.loads(j)

            CURSOR.execute(f"SELECT * FROM users WHERE email={js['username']}")
            if len(CURSOR.fetchall()) > 0:
                data = json.dumps({"pleasure": Classifier().pleasure_process_data(js["acts"], js["days"], js["humans"], js["cost"]), 
                                   "cost": Classifier().cost_process_data(js["acts"], js["days"], js["humans"], js["cost"])})
                log(data, "wmsg")
                data = data.encode()

                dl = len(data)

                s.send(struct.pack(">I", 1)+struct.pack(">I", dl)+data)
            else:
                s.send(struct.pack(">I", 0))
        else:
            s.send(struct.pack(">I", 0))
        # ERROR CODE IS 0, SUCCESS IS 1
    except Exception as e:
        log("Error in request handle: "+str(e), "err")

# mainloop
log("Running server")
while isRunning:
    try:
        conn, ip = SERVER.accept()
        threading.Thread(target=handle, args=(conn, ip)).start()
        log("Thread started. Request handling", "wmsg")
    except Exception as e:
        log("Exception in mainloop: "+str(e), "err")