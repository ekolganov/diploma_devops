FROM python:3.9.0-alpine3.12

EXPOSE 80/tcp

ENV_POSTGRES_DB
ENV_POSTGRES_USER
ENV_POSTGRES_PASSWORD
ENV_POSTGRES_HOST

WORKDIR /my-app
COPY setup.py .
COPY requirements.txt .
COPY app ./app
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install flask && \
    pip3 install psycopg2-binary
RUN python3 setup.py bdist_wheel
RUN pip3 install dist/nhl_stat_app_be*.whl

CMD nhl_stat_app_be
