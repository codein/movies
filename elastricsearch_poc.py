from datetime import datetime
from elasticsearch import Elasticsearch

# by default we connect to localhost:9200
es = Elasticsearch()

# datetimes will be serialized
# es.index(index="my-index", doc_type="test-type", id=42, body={"any": "data", "timestamp": datetime.now()})
# {u'_id': u'42', u'_index': u'my-index', u'_type': u'test-type', u'_version': 1, u'ok': True}

# but not deserialized
# print es.get(index="my-index", doc_type="test-type", id=42)['_source']
# {u'any': u'data', u'timestamp': u'2013-05-12T19:45:31.804229'}

doc = {
    'author': 'kimchy',
    'text': 'Elasticsearch: cool. bonsai cool.',
    'timestamp': datetime(2010, 10, 10, 10, 10, 10)
}
authors = [
    'robin',
    'john',
    'varghese',
    'sonia',
    'jacob',
    'paul',
    'maria'
]

for index, author in enumerate(authors):
    doc['author'] = author
    doc = {
        'author': author,
        'text': 'Elasticsearch: cool. bonsai cool. %s' % author
    }
    print doc,index

    # res = es.index(index="test-index", doc_type='tweet', id=index, body=doc)

query_body = {
    "query": {
        "fuzzy_like_this": {
            "fields" : ["author"],
            'like_text': 'mar'
        }
    }
}

match_all_query_body = {
    'query': {
        'match_all': {}
    }
}

res = es.search(index="test-index", body=match_all_query_body)
print("Got %d Hits:" % res['hits']['total'])
for hit in res['hits']['hits']:
    print hit["_source"]