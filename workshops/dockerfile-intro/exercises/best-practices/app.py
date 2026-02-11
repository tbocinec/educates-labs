from flask import Flask
import os

app = Flask(__name__)


@app.route("/")
def hello():
    user = os.popen("whoami").read().strip()
    return f"<h1>Best Practices Demo</h1><p>Running as user: <strong>{user}</strong></p>"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
