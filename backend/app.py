from flask import Flask, request, jsonify
from flask_cors import CORS


app = Flask(__name__)
CORS(app)


@app.route("/", methods=['POST'])
def get_data():
    """ Recieve start&end date from frontend """
    if request.method == "POST":
        data = request.get_json()
        print(data)
        results = {'status_recieved_data': 'true'}
        return jsonify(results)


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
