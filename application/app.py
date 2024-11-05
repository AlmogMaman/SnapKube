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
    if not url:
        app.logger.error('URL is required')
        return jsonify({'error': 'URL is required'}), 400

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
        filepath = f"/screenshots/{filename}"

        # Take screenshot
        driver.save_screenshot(filepath)

        # Read the screenshot file and encode it to base64
        with open(filepath, "rb") as image_file:
            encoded_string = base64.b64encode(image_file.read()).decode('utf-8')

        driver.quit()

        return jsonify({
            'status': 'success',
            'filepath': filepath,
            'image_data': encoded_string
        })

    except Exception as e:
        app.logger.error(f'Error taking screenshot: {str(e)}')
        return jsonify({'error': str(e)}), 500

@app.route('/health')
def health_check():
    return jsonify({'status': 'healthy'}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)



############################
"""
from flask import Flask, request, jsonify
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import os
import psycopg2
from datetime import datetime
from prometheus_client import Counter, Histogram
from prometheus_flask_exporter import PrometheusMetrics
import base64

app = Flask(__name__, template_folder='templates')

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

def get_db_connection():
    return psycopg2.connect(
        host=os.getenv('DB_HOST', 'postgres'),
        database=os.getenv('DB_NAME', 'screenshots'),
        user=os.getenv('DB_USER', 'postgres'),
        password=os.getenv('DB_PASSWORD')
    )

@app.route('/screenshot', methods=['POST'])
@screenshot_duration.time()
def take_screenshot():
    screenshot_requests.inc()
    url = request.json.get('url')
    if not url:
        return jsonify({'error': 'URL is required'}), 400

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
        filepath = f"/screenshots/{filename}"

        # Take screenshot
        driver.save_screenshot(filepath)

        # Read the screenshot file and encode it to base64
        with open(filepath, "rb") as image_file:
            encoded_string = base64.b64encode(image_file.read()).decode('utf-8')

        driver.quit()

        # Store metadata and image in database
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO screenshots (url, filepath, created_at, image_data) VALUES (%s, %s, %s, %s)",      
            (url, filepath, datetime.now(), encoded_string)
        )
        conn.commit()
        cur.close()
        conn.close()

        return jsonify({
            'status': 'success',
            'filepath': filepath
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/health')
def health_check():
    try:
        # Test DB connection
        conn = get_db_connection()
        conn.close()
        return jsonify({'status': 'healthy'}), 200
    except Exception as e:
        return jsonify({'status': 'unhealthy', 'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
"""