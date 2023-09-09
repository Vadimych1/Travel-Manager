# server
import http.server as httpserver
from http.server import HTTPStatus
import posixpath, mimetypes, html
import urllib
import struct

# database
import sqlite3 as sqlite
import json
import hashlib
import jwt

# other
import random
import os
import datetime, time
import colors
import requests

# classification
from classifier import Classifier

# logger
from logger import Log

# dir change
try:
    os.chdir("./Server/")
except Exception as e:
    Log("Error while changing directory: " + str(e), "wmsg")

# VK Service Key
VK_SERVICE_KEY = ""
with open("./service.key", "r") as f:
    VK_SERVICE_KEY = f.readline()

Log("VK Service Key: " + VK_SERVICE_KEY, "wmsg")

JWTKEY_LENGTH = 32

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

# Creating table "user_preferences"
CURSOR.execute("""CREATE TABLE IF NOT EXISTS user_preferences(
   userid INTEGER PRIMARY KEY,
   preferences TEXT);
""")

DATABASE.commit()

"""
REQUEST TYPES

login?login=...&password=...
login=str, password=hashed str

register?login=...&password=...&name=...
login=str, password=hashed str, name=str

jwtlogin?jwt=...&username=...
jwt=str(jwt format)

writeuserprefs?jwt=...&prefs=...
jwt=str(jwt format), prefs=str(json)
"""

"""
ERRORS

user not found - USER_NOT_FOUND
invalid password - INVALID_PASSWORD
user already exists - USER_ALREADY_EXIST
"""

class Handler(httpserver.BaseHTTPRequestHandler):
    server_version = "Travel Manager HTTP Server/0.0.1"
    extensions_map = _encodings_map_default = {
        '.gz': 'application/gzip',
        '.Z': 'application/octet-stream',
        '.bz2': 'application/x-bzip2',
        '.xz': 'application/x-xz',
    }

    def __init__(self, *args, directory=None, **kwargs):
        if directory is None:
            directory = os.getcwd()
        self.directory = os.fspath(directory)
        super().__init__(*args, **kwargs)

    def do_GET(self):
        print(self.path)
        try:
            path = self.path
            if path == "/favicon.ico":
                self.list_directory("/")
                return

            type, args_ = path.split('?')

            args = {}

            for arg in args_.split('&'):
                a, b = arg.split('=', 1)
                args[a] = b

            content_len = 0
        except Exception as e:
            self.list_directory("/")
            return

        toWrite = ""

        if type == "/login":
            try:
                login = args["login"]
                password = args["password"]
            except:
                Log("Exception while login", "warn")
                self.send_error(406, "Request hasn`t one of params 'login' or 'password' or both")
                return

            CURSOR.execute("SELECT * FROM users WHERE email='%s'"%login)
            user = CURSOR.fetchall()

            if len(user) == 0:
                toWrite = "USER_NOT_FOUND"
            else:
                user = user[0]
                userid, email, name, password, subto, jwtcode = user

                if password == args["password"]:
                    userjwt = jwt.encode({"username": email}, str(jwtcode))
                    toWrite+=userjwt
                    toWrite+="||"
                    toWrite+=json.dumps({"name": name, "subto": subto, "email": email})
                else:
                    toWrite = "INVALID_PASSWORD"
            
        elif type == "/register":
            try:
                login = args["login"].lower()
                password = args["password"]
                name = args["name"]
            except:
                Log("Exception while login", "warn")
                self.send_error(406, "Request hasn`t one of params 'login' or 'password' or 'name' or all")
                return

            CURSOR.execute("SELECT * FROM users WHERE email='%s'"%login)
            user = CURSOR.fetchone()

            if user is not None:
                toWrite = "USER_ALREADY_EXISTS"
            else:
                jwtcode = random_key(JWTKEY_LENGTH)
                CURSOR.execute("INSERT INTO users (email, name, password, subscribedto, jwtcode) VALUES (?, ?, ?, ?, ?)", [login, name, password, "notsub", jwtcode])
                DATABASE.commit()

                userjwt = jwt.encode({"username": login}, str(jwtcode))
                toWrite+=userjwt
                toWrite+="||"
                toWrite+=json.dumps({"name": name, "subto": "notsub", "email": login})

        elif type == "/jwtlogin":
            # TODO: jwt login logic
            try:
                login = args["login"]
                mjwt = args["jwt"]
            except:
                Log("Exception while login", "warn")
                self.send_error(406, "Request hasn`t one of params 'login' or 'jwt' or both")
                return
            
            
        elif type == "/writeuseprefs":
            # TODO: write user preferences
            ...
        else:
            self.list_directory("/")
            return
        
        toWrite = toWrite.encode("utf-8")

        self.send_response(HTTPStatus.OK)
        self.send_header("Content-type", "text/plain")
        self.send_header("Content-Length", str(len(toWrite)))
        self.send_header("Last-Modified",
        self.date_time_string(time.time()))
        self.end_headers()

        self.wfile.write(toWrite)

    def send_head(self):
        path = self.translate_path(self.path)
        f = None
        if os.path.isdir(path):
            parts = urllib.parse.urlsplit(self.path)
            if not parts.path.endswith('/'):
                self.send_response(HTTPStatus.MOVED_PERMANENTLY)
                new_parts = (parts[0], parts[1], parts[2] + '/',
                             parts[3], parts[4])
                new_url = urllib.parse.urlunsplit(new_parts)
                self.send_header("Location", new_url)
                self.send_header("Content-Length", "0")
                self.end_headers()
                return None
            for index in "index.html", "index.htm":
                index = os.path.join(path, index)
                if os.path.isfile(index):
                    path = index
                    break
            else:
                return self.list_directory(path)
        ctype = self.guess_type(path)

        if path.endswith("/"):
            self.send_error(HTTPStatus.NOT_FOUND, "File not found")
            return None
        try:
            f = open(path, 'rb')
        except OSError:
            self.send_error(HTTPStatus.NOT_FOUND, "File not found")
            return None

        try:
            fs = os.fstat(f.fileno())

            if ("If-Modified-Since" in self.headers
                    and "If-None-Match" not in self.headers):
                try:
                    ims = email.utils.parsedate_to_datetime(
                        self.headers["If-Modified-Since"])
                except (TypeError, IndexError, OverflowError, ValueError):
                    pass
                else:
                    if ims.tzinfo is None:
                        ims = ims.replace(tzinfo=datetime.timezone.utc)
                    if ims.tzinfo is datetime.timezone.utc:
                        last_modif = datetime.datetime.fromtimestamp(
                            fs.st_mtime, datetime.timezone.utc)
                        last_modif = last_modif.replace(microsecond=0)

                        if last_modif <= ims:
                            self.send_response(HTTPStatus.NOT_MODIFIED)
                            self.end_headers()
                            f.close()
                            return None

            self.send_response(HTTPStatus.OK)
            self.send_header("Content-type", ctype)
            self.send_header("Content-Length", str(fs[6]))
            self.send_header("Last-Modified",
                self.date_time_string(fs.st_mtime))
            self.end_headers()
            return f
        except:
            f.close()
            raise

    def list_directory(self, path):
        self.send_error(
            403,
            "Can`t serve this request")
        return None

    def translate_path(self, path):
        path = path.split('?',1)[0]
        path = path.split('#',1)[0]

        trailing_slash = path.rstrip().endswith('/')
        try:
            path = urllib.parse.unquote(path, errors='surrogatepass')
        except UnicodeDecodeError:
            path = urllib.parse.unquote(path)
        path = posixpath.normpath(path)
        words = path.split('/')
        words = filter(None, words)
        path = self.directory
        for word in words:
            if os.path.dirname(word) or word in (os.curdir, os.pardir):
                continue
            path = os.path.join(path, word)
        if trailing_slash:
            path += '/'
        return path

    def copyfile(self, source, outputfile):
        shutil.copyfileobj(source, outputfile)

    def guess_type(self, path):
        base, ext = posixpath.splitext(path)
        if ext in self.extensions_map:
            return self.extensions_map[ext]
        ext = ext.lower()
        if ext in self.extensions_map:
            return self.extensions_map[ext]
        guess, _ = mimetypes.guess_type(path)
        if guess:
            return guess
        return 'application/octet-stream'

    def log_message(self, format:str, *args):
        # Log(format % args, "warn")
        ...

    def send_error(self, code, message=None, explain=None):
        try:
            shortmsg, longmsg = self.responses[code]
        except KeyError:
            shortmsg, longmsg = '???', '???'

        if message is None:
            message = shortmsg
        if explain is None:
            explain = longmsg

        self.log_error("code %d, message %s", code, message)
        self.send_response(code, message)
        self.send_header('Connection', 'close')

        body = None
        if (code >= 200 and
            code not in (HTTPStatus.NO_CONTENT,
                         HTTPStatus.RESET_CONTENT,
                         HTTPStatus.NOT_MODIFIED)):

            content = f"<h1>Error {code}</h1><br><h3>{html.escape(message, quote=False)}</h3><br><h3>({html.escape(explain, quote=False)})</h3><style>*{{font-family:sans-serif; font-weight: 600}}</style>"
            body = content.encode('UTF-8', 'replace')

            self.send_header("Content-Type", self.error_content_type)
            self.send_header('Content-Length', str(len(body)))
        self.end_headers()

        if self.command != 'HEAD' and body:
            self.wfile.write(body)

# Create server
Log("Loading server")
SERVER = httpserver.ThreadingHTTPServer(RequestHandlerClass=Handler, server_address=("0.0.0.0",2020))

def random_key(length):
    number = '0123456789'
    alpha = 'abcdefghijklmnopqrstuvwxyz'
    id = ''
    for i in range(0,length,2):
        id += random.choice(number)
        id += random.choice(alpha)
    return id

def getCities(city):
    r = requests.get(f"https://api.vk.com/method/database.getCities?v=5.81&access_token={VK_SERVICE_KEY}&q={city}")
    return json.loads(r.content.decode("utf-8"))

Log("Server started")
SERVER.serve_forever()