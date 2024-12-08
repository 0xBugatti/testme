FROM python:3.9-slim


RUN apt-get update && \
    apt-get install -y python3-pip python3-dev libpq-dev \
        nginx curl \
        libjpeg-dev zlib1g-dev libfreetype6-dev liblcms2-dev \
        libwebp-dev tcl8.6-dev tk8.6-dev libharfbuzz-dev \
        libfribidi-dev libxcb1-dev \
        && apt-get clean


# Set environment variables for Django
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8080

# Set working directory
WORKDIR /app

# Copy requirements and install
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . /app/

# Set environment variables for superuser creation (example values)
# In a real scenario, pass these at runtime or via a secret manager
ENV DJANGO_SUPERUSER_USERNAME=admin \
    DJANGO_SUPERUSER_EMAIL=admin@example.com \
    DJANGO_SUPERUSER_PASSWORD=adminpass

# Expose port
EXPOSE 8080

# The CMD below will:
# 1. Run migrations
# 2. Attempt to create a superuser (will do nothing if user already exists)
# 3. Start the development server

CMD ["/bin/sh", "-c", "python manage.py makemigrations && \
    python manage.py migrate && \
    python manage.py createsuperuser --noinput || t
