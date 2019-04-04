FROM python:3.7-alpine

WORKDIR /app

COPY . /app

RUN pip install --trusted-host pypi.python.org -r requirements.txt

EXPOSE 80

ENV NAME Playground

ENTRYPOINT ["python3.7", "app.py"]
