FROM python:3.9.0-alpine3.12 

EXPOSE 5000/tcp

WORKDIR /my-app
COPY setup.py .
COPY requirements.txt .
COPY app ./app
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir flask psycopg2-binary Flask-Cors requests Flask-SQLAlchemy Flask-Migrate && \
    pip3 intsall --no-cache-dir prometheus-flask-exporter
RUN python3 setup.py bdist_wheel
RUN pip3 install dist/nhl_stat_app_be*.whl

CMD nhl_stat_app_be
