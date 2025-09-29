from flask import Flask, request, jsonify

app = Flask(__name__)

# Simule une base en mémoire (juste pour tester au début)
users = {"alice": "12345"}  # username: password
messages = []  # liste de messages (dictionnaires)

# Route LOGIN (POST JSON)
@app.route("/login", methods=["POST"])
def login():
    data = request.json
    username = data.get("username")
    password = data.get("password")
    if users.get(username) == password:
        return jsonify({"message": "Login success", "username": username}), 200
    return jsonify({"error": "Invalid credentials"}), 401

# Route GET MESSAGES
@app.route("/messages", methods=["GET"])
def get_messages():
    return jsonify(messages[::-1][:10]), 200

# Route POST MESSAGE
@app.route("/messages", methods=["POST"])
def post_message():
    data = request.json
    message = {
        "author": data.get("author"),
        "content": data.get("content")
    }
    messages.append(message)
    return jsonify(message), 201

if __name__ == "__main__":
    app.run(debug=True)