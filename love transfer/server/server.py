from http.server import BaseHTTPRequestHandler, HTTPServer
import time
import os
import json
hostName = "0.0.0.0"
serverPort = 1234
def doesexist(localpath):
    TEST_FILENAME = os.path.join(os.path.dirname(__file__), localpath)
    return os.path.exists(TEST_FILENAME)
def filefromlocalpath(localpath):
    TEST_FILENAME = os.path.join(os.path.dirname(__file__), localpath)
    with open(TEST_FILENAME) as f:
        lines = f.read()
        return bytes(lines, "utf-8")
def getfilenames(localpath):
    TEST_FILENAME = os.path.join(os.path.dirname(__file__), localpath)
    return json.dumps(os.listdir(TEST_FILENAME))
def handlerequest(path):
    if path != "/":
        if doesexist("files/" + path[1:len(path)]):
            return filefromlocalpath("files\\" + path[1:len(path)])
        else:
            return bytes("Error: file doesn't exist", "utf-8")
    else:
        return bytes("Python server for lua" + getfilenames("files"), "utf-8")
class MyServer(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()
        self.wfile.write(handlerequest(self.path))
if __name__ == "__main__":
    webServer = HTTPServer((hostName, serverPort), MyServer)
    print("Server started http://%s:%s" % (hostName, serverPort))

    try:
        webServer.serve_forever()
    except KeyboardInterrupt:
        pass

    webServer.server_close()
    print("Server stopped.")