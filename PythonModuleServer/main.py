import http.server as hts
import json
import requests

with open('config.json') as config_file:
    config = json.load(config_file)

MODULE_NAMES = []
MODULES = {}

for module in config['modules']:
    if module['enabled']:
        MODULE_NAMES.append(module['name'])
        MODULES[module['name']] = module

class Handler(hts.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()

        mName = self.headers.get("ModuleName")
        if mName == None:
            self.wfile.write(json.dumps({"responce": "error", "message": "no ModuleName header found"}).encode())
            return
        
        if mName in MODULE_NAMES:
            try:
                r = requests.get(f"http://localhost:{MODULES[mName]['port']}", 
                            data=self.rfile.read(int(
                                self.headers['Content-Length'] if self.headers["Content-Length"] else 0,
                                ),
                            ),
                        )
                r.raise_for_status()
            except Exception as e:
                self.wfile.write(json.dumps({"responce": "error", 
                                             "message": f"requested module on localhost:{MODULES[mName]['port']} is not responding",
                                             "error": str(e),
                                             }).encode())
                return

            self.wfile.write(r.content)
        else:
            self.wfile.write(json.dumps({"responce": "error", "message": "no required module found"}).encode())

httpd = hts.HTTPServer((config['host'], config['port']), Handler)
print("::LOG:: Serving at port", config['port'])
httpd.serve_forever()