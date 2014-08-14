"""
Test constitues

* test suggestions end point
* test movies end point.
"""


import requests
import json
import shutil
import httplib
import unittest

class TestSequenceFunctions(unittest.TestCase):
    """container to hold different test scenarios."""
    def setUp(self):
        self.base_url = 'http://localhost:8888'

    def _get_url(self, path):
        """given a relative path, return full url"""
        return '%s/%s' % (self.base_url, path)

    def test1_suggestions(self):
        """
        Ensure a user query receives appropriate suggestions
        """
        data = self.get('suggest/commandments')
        self.assertTrue('commandments' in data['suggestions'][0])

    def _loads_response(self, response):
        """given a response object json.loads the data and return."""
        if response.status_code == httplib.OK:
            return json.loads(response.text)

    def get(self, path, data=None):
        """helper to make GET requests"""
        url = self._get_url(path)
        response = requests.get(url)
        return self._loads_response(response)

if __name__ == '__main__':
    unittest.main()