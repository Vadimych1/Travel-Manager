import http.server as hts
import Parser as p

MODULE_PORT = 1000

def process(self: hts.BaseHTTPRequestHandler) -> str:
    # Process data here
    p.main(self.rfile.read(int(self.headers['Content-Length'])))

    data = ""

    return data

class Handler(hts.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()

        # HERE THE REQUEST PROCESSING
        resp = process(self)

        self.wfile.write(resp.encode())

httpd = hts.HTTPServer(('localhost', MODULE_PORT), Handler)
print("::LOG:: Serving at port", MODULE_PORT)
httpd.serve_forever()