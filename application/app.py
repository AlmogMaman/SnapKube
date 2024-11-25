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
    screenshot_requests.inc()  # Increment the counter
    start_time = datetime.now()

    try:
        data = request.get_json()
        url = data.get('url')

        if not url:
            return jsonify({'error': 'URL is required'}), 400

        # Validate URL format
        if not re.match(r'^https?://.+', url):
            return jsonify({'error': 'Invalid URL format. URL must start with http:// or https://'}), 400

        chrome_options = Options()
        chrome_options.add_argument('--headless')
        chrome_options.add_argument('--no-sandbox')
        chrome_options.add_argument('--disable-dev-shm-usage')
        chrome_options.add_argument('--disable-gpu')
        chrome_options.add_argument('--window-size=1920,1080')

        driver = webdriver.Chrome(options=chrome_options)
        driver.set_page_load_timeout(30)  # 30 seconds timeout

        try:
            driver.get(url)
            # Wait for page to load
            driver.implicitly_wait(5)
            
            # Take screenshot
            screenshot = driver.get_screenshot_as_png()
            
            # Convert to base64 for preview
            screenshot_base64 = base64.b64encode(screenshot).decode('utf-8')
            
            # Get metadata
            metadata = extract_metadata(screenshot)
            
            # Save to database
            with get_db_connection() as conn:
                with conn.cursor() as cur:
                    cur.execute(
                        """
                        INSERT INTO screenshots (url, image, metadata, created_by)
                        VALUES (%s, %s, %s, %s)
                        RETURNING id
                        """,
                        (url, screenshot, metadata, getpass.getuser())
                    )
                    screenshot_id = cur.fetchone()[0]
                conn.commit()

            app.logger.info(f'Screenshot taken successfully for URL: {url}')
            
            # Return both success message and base64 image for preview
            return jsonify({
                'status': 'success',
                'message': 'Screenshot taken successfully',
                'id': screenshot_id,
                'image': screenshot_base64
            })

        except Exception as e:
            app.logger.error(f'Error taking screenshot: {str(e)}')
            return jsonify({'error': f'Failed to take screenshot: {str(e)}'}), 500
        finally:
            driver.quit()

    except Exception as e:
        app.logger.error(f'Error processing request: {str(e)}')
        return jsonify({'error': str(e)}), 500
    finally:
        duration = (datetime.now() - start_time).total_seconds()
        screenshot_duration.observe(duration)

@app.route('/health')
def health_check():
    return jsonify({'status': 'healthy'}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
