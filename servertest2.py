import socket, struct, json
import hashlib


s = socket.create_connection(("127.0.0.1", 2020))

login = input("Логин > ")
password = input("Пароль > ")

userinfo = json.dumps({"name": "Вадим", 
"email": login, 
"password":hashlib.sha256(password.encode()).hexdigest()}).encode()

s.send(struct.pack(">I", 0)+struct.pack(">I",len(userinfo))+userinfo)

code = s.recv(4)
code = struct.unpack(">I", code)[0]

if code == 1:
    print("Successful login")
else:
    print("Uncorrect password")
    quit()

s.close()
s = socket.create_connection(("127.0.0.1", 2020))

data = {"username": login, 
"acts": int(input("Активности > ")),
"days": int(input("Дни > ")),
"humans": int(input("Люди > ")),
"cost": int(input("Стоимость > ")),
}
data = json.dumps(data).encode()

s.send(struct.pack(">I", 3)+struct.pack(">I",len(data))+data)

code = s.recv(4)
code = struct.unpack(">I", code)[0]


if code == 1:
    print("Successful")

    l = s.recv(4)
    l = struct.unpack(">I", l)[0]

    data = s.recv(l)
    data = data.decode("utf-8")

    JWT_ = data
    JWT_ = json.loads(JWT_)

    print("Processed data: "+data)
else:
    l = s.recv(4)
    l = struct.unpack(">I", l)[0]

    data = s.recv(l)
    data = data.decode("utf-8")

    Log(data, "err")
    quit()

s.close()