from flask import Flask
app = Flask(__name__)

import app.server

__version__ = '0.0.10'
