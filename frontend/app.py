from flask import Flask, render_template, send_from_directory
import os

app = Flask(__name__)


@app.route("/", methods=['GET'])
def get_data():
    """ Render main page and static content """

    return render_template("base.html", mytitle="NHL Stats", backend_uri="http://192.168.0.108:5000/")


@app.route('/favicon.ico')
def favicon():
    return send_from_directory(os.path.join(app.root_path, 'static'),
                               'favicon.ico', mimetype='image/vnd.microsoft.icon')


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80)
