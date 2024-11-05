# Start from a base Python image
FROM python:3.9-slim

# Update pip to the latest version
RUN python -m pip install --upgrade pip

# Install Chrome and Chrome WebDriver
RUN apt-get update && apt-get install -y  \
    chromium \
    chromium-driver \
    libglib2.0-0 \
    libnss3 \
    libgconf-2-4 \
    libfontconfig1 \
    wget \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Verify that io.open is available in the Python environment
RUN python -c "import io; print(io.open)"

# Create app directories
WORKDIR /app
RUN mkdir -p /app/logs /screenshots \
    && chmod -R 755 /app /screenshots \
    && chmod 666 /dev/stdout /dev/stderr /dev/stdin

# Copy application code and install dependencies.
COPY . .
RUN pip install --no-cache-dir -r requirements.txt && pip check

# Set environment variables
ENV CHROME_BIN=/usr/bin/chromium \
    CHROMEDRIVER_PATH=/usr/bin/chromedriver \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=""

# Expose port
EXPOSE 5000

# Run app
CMD ["python", "app.py"]



# FROM python:3.9-slim

# # Install Chrome and Chrome WebDriver
# RUN apt update && apt install -y \
#     chromium \
#     chromium-driver \
#     libglib2.0-0 \
#     libnss3 \
#     libgconf-2-4 \
#     libfontconfig1 \
#     wget \
#     gnupg \
#     && rm -rf /var/lib/apt/lists/*
# # RUN apt update && apt install -y \
# #     chromium-browser \
# #     chromium-driver \
# #     wget \
# #     gnupg \
# #     && rm -rf /var/lib/apt/lists/*

# # Create app directories
# WORKDIR /app
# RUN mkdir -p /app/logs /screenshots && chmod 777 /screenshots

# # Copy application code and install dependenceis.
# COPY . .
# RUN pip install --no-cache-dir -r requirements.txt


# # Set environment variables
# ENV CHROME_BIN=/usr/bin/chromium \
#     CHROMEDRIVER_PATH=/usr/bin/chromedriver \
#     PYTHONUNBUFFERED=1

# # Expose port
# EXPOSE 5000

# # Run app
# CMD ["python", "app.py"]