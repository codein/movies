from elasticsearch import Elasticsearch

from movies import movies
from movies_test import movies as movies_test

# by default we connect to localhost:9200
es = Elasticsearch()

def load_test_movies():
    for movie in movies_test:
        print movie
        print movie['title']

        res = es.index(index="test-movie-index", doc_type='movie', id=movie['title'], body=movie)

def load_movies():
    for movie in movies:
        # print movie
        # print movie['title']
        addresses = [location['address'] for location in movie['locations']]
        movie['addresses'] = addresses
        res = es.index(index="movie-index", doc_type='movie', id=movie['title'], body=movie)


def search_poc(query):
    query_body = {
        "query": {
            "fuzzy_like_this": {
                "fields" : ["title"],
                'like_text': query
            }
        }
    }

    match_all_query_body = {
        'query': {
            'match_all': {}
        }
    }

    res = es.search(index="movie-index", body=query_body)
    print("Got %d Hits:" % res['hits']['total'])
    print res['hits']['hits'][0]['_source']
    for hit in res['hits']['hits']:
        print hit["_source"]['title']

search_poc('The Rock')
# load_movies()