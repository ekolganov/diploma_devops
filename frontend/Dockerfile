FROM python:3.9.0-alpine3.12

EXPOSE 80/tcp

WORKDIR /my-app
COPY setup.py .
COPY requirements.txt .
COPY app ./app
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install flask && \
    pip3 install psycopg2-binary
RUN python3 setup.py bdist_wheel
RUN pip3 install dist/nhl_stat_app_fe-0.0.2-py3-none-any.whl

CMD nhl_stat_app_fe
