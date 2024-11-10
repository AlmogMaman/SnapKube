import unittest
from application.app import app
import re

class TestScreenshotApp(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True

    def test_home_page(self):
        response = self.app.get('/')
        self.assertEqual(response.status_code, 200)

    def test_url_validation(self):
        # Test valid URL
        response = self.app.post('/screenshot', data={'url': 'https://example.com'})
        self.assertEqual(response.status_code, 200)

        # Test invalid URL
        response = self.app.post('/screenshot', data={'url': 'invalid-url'})
        self.assertEqual(response.status_code, 400)

    def test_url_pattern(self):
        valid_urls = [
            'https://example.com',
            'http://test.com',
            'https://sub.domain.com'
        ]
        
        invalid_urls = [
            'ftp://example.com',
            'example.com',
            'not-a-url'
        ]

        for url in valid_urls:
            self.assertTrue(re.match(r'^(http|https)://', url))

        for url in invalid_urls:
            self.assertFalse(re.match(r'^(http|https)://', url)) 