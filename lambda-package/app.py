from flask import Flask, request, jsonify
from mangum import Mangum

app = Flask(__name__)


users = {"alice": "12345"} 
messages = [] 


@app.route("/login", methods=["POST"])
def login():
    data = request.json
    username = data.get("username")
    password = data.get("password")
    if users.get(username) == password:
        return jsonify({"message": "Login success", "username": username}), 200
    return jsonify({"error": "Invalid credentials"}), 401


@app.route("/messages", methods=["GET"])
def get_messages():
    return jsonify(messages[::-1][:10]), 200


@app.route("/messages", methods=["POST"])
def post_message():
    data = request.json
    message = {
        "author": data.get("author"),
        "content": data.get("content")
    }
    messages.append(message)
    return jsonify(message), 201

handler = Mangum(app)