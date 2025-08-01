FROM python:3.10-slim-bullseye
WORKDIR /app/django_project
COPY . /app/
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install gunicorn
EXPOSE 8000
ENV PYTHONUNBUFFERED=1
ENV DJANGO_SETTINGS_MODULE=myproject.settings
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--log-level", "debug", "myproject.wsgi:application"]
RUN apt-get update && apt-get install -y curl --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN echo "--- Listing /app contents ---"
RUN ls -R /app
RUN echo "--- Verifying Python import ---"
RUN python <<EOF
import os
import sys
print('Current working directory:', os.getcwd())
print('sys.path:', sys.path)
sys.path.insert(0, '/app')
print('Updated sys.path:', sys.path)
try:
    from myproject.wsgi import application
    print('application found and importable!')
except ImportError as e:
    print('ImportError: ' + str(e))
    sys.exit(1)

EOF
RUN echo "--- Python import check complete ---"