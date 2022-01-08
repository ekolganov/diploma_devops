from flask import Flask, request, jsonify
from flask_cors import CORS
from typing import Dict, List
import requests
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
import psycopg2
import os


class Config(object):
    SQLALCHEMY_DATABASE_URI = "postgresql://postgres:testpassword@192.168.0.108:5432/postgres"
    SQLALCHEMY_TRACK_MODIFICATIONS = False


app = Flask(__name__)
app.config.from_object(Config)
CORS(app)
db = SQLAlchemy(app)
migrate = Migrate(app, db)

con = psycopg2.connect(
    #database=os.environ.get("POSTGRES_DB"),
    #user=os.environ.get("POSTGRES_USER"),
    #password=os.environ.get("POSTGRES_PASSWORD"),
    #host="postgres"
    database="postgres",
    user="postgres",
    password="testpassword",
    host="192.168.0.108"
    )
cur = con.cursor()


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

    def __init__(self, id, game_id, link, date, teams, score, stars):
        self.id = id
        self.game_id = game_id
        self.link = link
        self.date = date
        self.teams = teams
        self.score = score
        self.stars = stars


@app.route("/", methods=['POST'])
def get_data():
    """ Receive start&end date from frontend and return games and stats to frontend """

    if request.method == "POST":
        data = request.get_json()
        nhl_api_do_request(data[0]['ds'], data[1]['de'])
        games = get_games_period_dict(data[0]['ds'], data[1]['de'])
        return jsonify(games)


def get_games_period_dict(date_start: str, date_end: str) -> List[Dict]:
    """ from period date fetch games from DB """

    cur.execute(f"SELECT * from nhl_games where date between '{date_start}' and '{date_end}' order by date;")
    rows = cur.fetchall()

    res = []
    for game_data in rows:
        res.append({
                    "date": str(game_data[3].strftime("%Y-%m-%d %H:%M")),
                    "teams": game_data[4],
                    "score": game_data[5],
                    "stars": game_data[6]
                    })
    return res


def nhl_api_do_request(_ds: str, _de: str):
    """
    Search game stats and stars in Enterprise Center arena by nhl api
    If game not in DB then insert
    """

    def _get_exist_games_id() -> set:
        cur.execute("SELECT game_id from nhl_games")
        rows = cur.fetchall()
        _exist_games_id = set(i for sub in rows for i in sub)
        return _exist_games_id

    def _nhl_api_search_game_stars(_link_game: str) -> str:
        """ Return 1st, 2nd, 3d game stars """

        _resp = requests.get(nhl_api_uri + _link_game)
        _json_resp = _resp.json()

        s1 = _json_resp['liveData']['decisions']['firstStar']['fullName']
        s2 = _json_resp['liveData']['decisions']['secondStar']['fullName']
        s3 = _json_resp['liveData']['decisions']['thirdStar']['fullName']

        return f"{s1}, {s2}, {s3}"

    nhl_api_uri = "https://statsapi.web.nhl.com/"
    nhl_api_uri_broadcast = f"api/v1/schedule.broadcasts?startDate={_ds}&endDate={_de}"

    resp = requests.get(nhl_api_uri+nhl_api_uri_broadcast)
    json_resp = resp.json()

    exist_games_id = _get_exist_games_id()

    for dates in json_resp['dates']:
        for game in dates['games']:
            for venue, v_id in game['venue'].items():
                # id 5076 - Enterprise Center's id
                if v_id == 5076 and game['gamePk'] not in exist_games_id:
                    game_stars = _nhl_api_search_game_stars(game['link'])

                    teams = f"{game['teams']['home']['team']['name']} - {game['teams']['away']['team']['name']}"
                    score = f"{game['teams']['home']['score']} - {game['teams']['away']['score']}"

                    data = Games(id=None,
                                 game_id=game["gamePk"],
                                 link=game['link'],
                                 date=game['gameDate'],
                                 teams=teams,
                                 score=score,
                                 stars=game_stars
                                 )
                    db.session.add(data)
                    db.session.commit()
    con.rollback()
    return


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
