from flask import Flask
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
import os

__version__ = '0.1.16'

PG_DB = os.environ.get("ENV_POSTGRES_DB")
PG_USER = os.environ.get("ENV_POSTGRES_USER")
PG_PSWD = os.environ.get("ENV_POSTGRES_PASSWORD")
PG_HOST = os.environ.get("ENV_POSTGRES_HOST")

class Config(object):
    SQLALCHEMY_DATABASE_URI = f"postgresql://{PG_USER}:{PG_PSWD}@{PG_HOST}:5432/{PG_DB}"
    SQLALCHEMY_TRACK_MODIFICATIONS = False


app = Flask(__name__)
app.config.from_object(Config)
CORS(app)
db = SQLAlchemy(app)
migrate = Migrate(app, db)


class Games(db.Model):
    """ Flask model to add in DB data """

    __tablename__ = 'nhl_games'

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    game_id = db.Column(db.Integer)
    link = db.Column(db.String())
    date = db.Column(db.DateTime)
    teams = db.Column(db.String())
    score = db.Column(db.String())
    stars = db.Column(db.String())
#    test = db.Column(db.Integer, autoincrement=True)

    def __init__(self, id, game_id, link, date, teams, score, stars):
#    def __init__(self, id, game_id, link, date, teams, score, stars, test):
        self.id = id
        self.game_id = game_id
        self.link = link
        self.date = date
        self.teams = teams
        self.score = score
        self.stars = stars
#        self.test = test
