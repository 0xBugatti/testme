# Step 1: Use the official Python image
FROM python:3.9-slim as base

# Step 2: Install system dependencies
RUN apt-get update && apt-get install -y \
    python3-pip \
    libpq-dev \
    postgresql \
    && apt-get clean

# Step 3: Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Step 4: Set the working directory
WORKDIR /app

# Step 5: Install Python dependencies
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Step 6: Copy project files
COPY . /app/

# Step 7: Set up PostgreSQL
RUN service postgresql start && \
    sudo -u postgres psql -c "CREATE DATABASE mydb;" && \
    sudo -u postgres psql -c "CREATE USER myuser WITH PASSWORD 'mypassword';" && \
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE mydb TO myuser;"

# Step 8: Configure Django settings for PostgreSQL
RUN sed -i "s/ENGINE': 'django.db.backends.sqlite3/ENGINE': 'django.db.backends.postgresql_psycopg2/" /app/settings.py && \
    sed -i "s/NAME': 'db.sqlite3/NAME': 'mydb', 'USER': 'myuser', 'PASSWORD': 'mypassword', 'HOST': 'localhost', 'PORT': '5432'/" /app/settings.py

# Step 9: Expose port for Cloud Run
EXPOSE 8080

# Step 10: Run migrations and start the server
CMD ["sh", "-c", "service postgresql start && python manage.py migrate && gunicorn --bind 0.0.0.0:8080 projectname.wsgi"]
