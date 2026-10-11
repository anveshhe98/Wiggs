web: gunicorn --bind 0.0.0.0:$PORT --worker-class gevent bot_upgraded:app
worker: python bot_upgraded.py
