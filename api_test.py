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

    def test_default_search(self):
        """
        Tests the default search without any fields
        Default field is title
        """
        data = self.get('movies?query=commandments')
        self.assertTrue('The Ten Commandments' in data['movies'][0]['title'])

    def test_distributor_search(self):
        """
        Tests a field specific query
        Ensure the fuzzy search works
        """
        data = self.get('movies?query=Twentieth+Century+Fox&field=distributor')
        distributors = [
            'Twentieth Century Fox',
            'Twentieth Century - Fox',
            'Twentieth Century Fox Corporation',
            'Twentieth Century Fox Film Corp.',
            'Twentieth Century Fox Film Corporation',
            'Twentieth Century Fox Film Corp.'
        ]
        distributors_set = set(iter(distributors))

        distributors_set_from_api = set()
        for movie in data['movies']:
            distributors_set_from_api.add(movie['distributor'])

        self.assertTrue(distributors_set == distributors_set_from_api)

    def test_field_search(self):
        """
        Tests a field specific query
        Ensure the query term is in the first hit.
        """
        test_suites = [
            {
                'field': 'director',
                'query': 'George Lucas'
            },
            {
                'field': 'release_year',
                'query': '2014'
            },
            {
                'field': 'title',
                'query': 'Commandments'
            },
            {
                'field': 'addresses',
                'query': 'Golden Gate Park'
            },
            {
                'field': 'actors',
                'query': 'Adam Sandler'
            },
            {
                'field': 'writer',
                'query': 'Max Borenstein'
            },
            {
                'field': 'production_company',
                'query': 'Paramount Pictures'
            },
            {
                'field': 'distributor',
                'query': 'Warner Bros. Pictures'
            },
            {
                'field': 'fun_facts',
                'query': 'Alcatraz Island was a military fort before it became a prison.'
            },
        ]
        for test_suite in test_suites:
            query = test_suite['query']
            field = test_suite['field']
            requests.utils.quote(query)
            data = self.get('movies?query=%s&field=%s' % (requests.utils.quote(query), field))
            self.assertTrue(query in data['movies'][0][field])

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