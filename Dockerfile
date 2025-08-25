# Base image: lightweight Debian + Python 3.12
FROM python:3.12-slim

# Environment settings
ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# Create working directory inside container
WORKDIR /app

# System dependencies (needed for some Python libs)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
 && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt && pip install gunicorn

# Copy your app code into the image
COPY idf_tool ./idf_tool
COPY templates ./templates
COPY static ./static
COPY uploads ./uploads
COPY submits ./submits

# Ensure folders exist (for volumes)
RUN mkdir -p /app/uploads /app/submits

# Add a non-root user
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

# Expose app port
EXPOSE 8000

# Run with Gunicorn (production WSGI server)
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "idf_tool.app:app"]
