from flask import Flask
from flask import request

app = Flask(__name__)

@app.before_request
def sup():
    print("sup")

@app.route("/twin")
def hello():
    return "Hello, World!"

@app.route("/twin/")
def different():
    return "This is a different page"