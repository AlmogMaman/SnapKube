from flask import Flask, request, jsonify, render_template
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import os
from datetime import datetime
from prometheus_client import Counter, Histogram
from prometheus_flask_exporter import PrometheusMetrics
import base64
import logging
from logging_config import setup_logging
import psycopg2
from psycopg2 import sql
import getpass  # Import getpass for user information
from image_metedata import extract_metadata
import re

app = Flask(__name__, template_folder='templates')
setup_logging(app)  # Set up logging

# Initialize Prometheus metrics
metrics = PrometheusMetrics(app)
screenshot_requests = Counter(
    'screenshot_requests_total',
    'Total number of screenshot requests'
)
screenshot_duration = Histogram(
    'screenshot_duration_seconds',
    'Time spent processing screenshots'
)

# Database connection parameters
DB_HOST = os.getenv('DB_HOST', 'postgres')
DB_NAME = os.getenv('DB_NAME', 'screenshots')
DB_USER = os.getenv('DB_USER', 'root')
DB_PASSWORD = os.getenv('DB_PASSWORD', '142536')

def get_db_connection():
    return psycopg2.connect(
        host=DB_HOST,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD
    )

@app.errorhandler(500)
def internal_error(error):
    app.logger.error(f'Internal Server Error: {error}')
    return jsonify({'error': 'Internal Server Error'}), 500

@app.errorhandler(404)
def not_found(error):
    app.logger.error(f'Not Found: {error}')
    return jsonify({'error': 'Not Found'}), 404
    
@app.route('/')
def index():
    return render_template('index.html')

@app.route('/screenshot', methods=['POST'])
@screenshot_duration.time()
def take_screenshot():
    screenshot_requests.inc()
    url = request.json.get('url')
    
    # Validate URL format using regex
    if not url or not re.match(r'^(http|https)://', url):
        app.logger.error('Invalid URL format')
        return jsonify({'error': 'Invalid URL format. Please provide a valid URL starting with http:// or https://'}), 400

    try:
        # Setup Chrome in headless mode
        chrome_options = Options()
        chrome_options.add_argument('--headless')
        chrome_options.add_argument('--no-sandbox')
        chrome_options.add_argument('--disable-dev-shm-usage')

        driver = webdriver.Chrome(options=chrome_options)
        driver.get(url)

        # Generate filename
        filename = f"screenshot_{datetime.now().strftime('%Y%m%d_%H%M%S')}.png"
        file_path = f"/screenshots/{filename}"

        # Take screenshot
        driver.save_screenshot(file_path)

        # Read the screenshot file and encode it to base64
        with open(file_path, "rb") as image_file:
            encoded_string = base64.b64encode(image_file.read()).decode('utf-8')

        
        info = {
            'screenshot_id' : abs(hash(file_path)) % (10**10),  # unique number based on the file path
            'timestamp': datetime.now().isoformat(),
            'page_url': url,
            'width': 0,
            'height': 0,
            'file_format': '',
            'file_size': 0, #bigin
            'creation_time':  datetime.now().isoformat(),
            'modification_time':  datetime.now().isoformat(),

            'username': getpass.getuser(),
            'user_id': os.getuid(),
        }
        info['width'], info['height'], info['file_format'], info['file_size'], info['creation_time'], info['modification_time'] = extract_metadata(file_path)

        # connect to the db
        connection = get_db_connection()
        cursor = connection.cursor()


        cursor.execute(
        sql.SQL("INSERT INTO user_screenshots (page_url, user_id, screenshot_id, timestamp, width, height, file_format, file_size, creation_time, modification_time) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"),
        (info['page_url'], info['user_id'], info['screenshot_id'], info['timestamp'], info['width'], info['height'], info['file_format'], info['file_size'], info['creation_time'], info['modification_time'])
        )
            
        connection.commit()

        msg = jsonify({
            'status': 'success',
            'file_path': file_path,
            'image_data': encoded_string
        })

    except Exception as e:
        app.logger.error(f'Error taking screenshot/updating the db: {str(e)}')
        return jsonify({'error': str(e)}), 500
    finally:
        driver.quit()
        if cursor:
            cursor.close()
        if connection:
            connection.close()
    return msg
@app.route('/health')
def health_check():
    return jsonify({'status': 'healthy'}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
