"""
tornado web server
Implements a API endpoint to search movies by specific field
"""

import json
import logging
from operator import itemgetter

from elasticsearch import Elasticsearch
import tornado.ioloop
import tornado.web
import tornado.gen

LOG_FORMAT = '%(asctime)s - %(filename)s:%(lineno)s - %(levelname)s - %(message)s'
logging.basicConfig(format=LOG_FORMAT, level=logging.INFO)


class BaseRequestHandler(tornado.web.RequestHandler):
    """Base Handler with capabiblity to write json data back"""

    @property
    def es(self):
        """elastic search property from the main application object is referenced"""
        if not hasattr(self, '_es'):
            self._es = self.application.es

        return self._es

    def json_write(self, data, field='data'):
        """Given a python dict wraps it in a data attribute and returned."""
        self.set_header(name="Content-Type", value="application/json")
        self.write(json.dumps({field: data}))
        self.finish()


@tornado.gen.coroutine
def search(es, query, fields=['title']):
    """
    Given a query and field, translate it into elasticsearch query.
    Finally return the results
    """
    query_body = {
        "query": {
            "fuzzy_like_this": {
                "fields" : fields,
                'like_text': query
            }
        }
    }

    res = es.search(index="movie-index", body=query_body)
    logging.info("Got %d Hits for %s", res['hits']['total'], query)
    search_results = [hit["_source"] for hit in res['hits']['hits']]

    raise tornado.gen.Return(search_results)


class MovieRequestHandler(BaseRequestHandler):
    """
    Handler to server /movie endpoint
    """

    @tornado.web.asynchronous
    @tornado.gen.coroutine
    def get(self, query):
        """
        return movies for a given query.
        """
        query = self.get_argument('query', default='')
        fields = self.get_arguments('field')
        if len(fields) == 0:
            fields = ['title']

        search_results = yield search(self.es, query, fields)
        self.json_write(search_results, 'movies')


class App(tornado.web.Application):
    """
    Main app, servers both the static assets required for the app.
    Also supports the API search endpoint.
    """
    handlers = [
        (r"/movies/*([a-zA-Z0-9-]*)", MovieRequestHandler),
        (r'/static/(.*)', tornado.web.StaticFileHandler, {'path': './'}),
    ]

    def __init__(self):
        tornado.web.Application.__init__(self, self.handlers, debug=True)

    @property
    def es(self):
        """intantiates a connection to elastic search server"""
        if not hasattr(self, '_es'):
            self._es = Elasticsearch()

        return self._es


if __name__ == "__main__":
    application = App()
    application.listen(8888)
    tornado.ioloop.IOLoop.instance().start()
