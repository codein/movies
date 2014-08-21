from elasticsearch import Elasticsearch

from movies_test import movies

# by default we connect to localhost:9200
es = Elasticsearch()

for movie in movies:
    print movie
    print movie['title']

    # res = es.index(index="test-movie-index", doc_type='movie', id=movie['title'], body=movie)

query_body = {
    "query": {
        "fuzzy_like_this": {
            "fields" : ["title"],
            'like_text': 'Commandments'
        }
    }
}

match_all_query_body = {
    'query': {
        'match_all': {}
    }
}

res = es.search(index="test-movie-index", body=query_body)
print("Got %d Hits:" % res['hits']['total'])
for hit in res['hits']['hits']:
    print hit["_source"]