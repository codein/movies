"""
Script to enginner the raw csv data
1. Retrieves latitude and longitude for each locations
2. Groups all records by common_movie_attributes for ex. title.

usage
python data_engineering.py
"""

import csv
import json
from itertools import groupby
from pprint import pprint

from pygeocoder import Geocoder
from pygeolib import GeocoderError


FILE_NAME = 'Film_Locations_in_San_Francisco test.csv'
FILE_NAME = 'Film_Locations_in_San_Francisco.csv'

def get_title(record):
    """given a record returns it's title"""
    return record.get('title', None)

"""
1. Reads records from .csv
2. Retrieves latitude and longitude for each locations
3. Groups all records by common_movie_attributes for ex. title.
4. Finally writes the data into .js file
for ex a final record for a movie is as follows
{
    "title":"Midnight Lace",
    "fun_facts":["In 1945 the Fairmont hosted the United Nations Conference on... ],
    "writer":"Ivan Geoff",
    "locations":[{"latitude":37.7924,"longitude":-122.4102,"address":"Fairmont Hotel (950 Mason Street, Nob Hill)"}],
    "director":"David Miller",
    "production_company":"Arwin Productions",
    "actors":["","Rex Harrison","Doris Day"],
    "distributor":"Universal Pictures"
}
"""

with open(FILE_NAME, 'rb') as csvfile:
    spamreader = csv.reader(csvfile, delimiter=',')
    headers = []
    records = []
    for row_no,row in enumerate(spamreader):
        if row_no == 0:
            headers = [header.lower().replace(' ', '_') for header in row]
        else:
            record = {'id': row_no}
            for column_no, column_value in enumerate(row):
                column_name = headers[column_no]
                record[column_name] = column_value

            address = '%s %s'% (record.get('locations', ''), 'San Francisco CA')
            try:
                results = Geocoder.geocode(address)
                latitude, longitude = results[0].coordinates
            except GeocoderError, e:
                print 'no locations found'
                latitude, longitude = (37.758895, -122.41472420000002)

            record['latitude'] = latitude
            record['longitude'] = longitude
            records.append(record)
            if row_no % 20 == 0:
                print row_no

    print len(records), 'movies found'

    movies = []
    # attributes that records have in common
    common_movie_attributes = [
        'title',
        'release_year',
        'production_company',
        'distributor',
        'director',
        'writer',
    ]

    more_movie_attributes = [
        'locations',
        'fun_facts',
        'actors',
    ]

    for movie_title, records_group_generator in groupby(records, key=get_title):
        movie = {}
        records_group = list(records_group_generator)
        first_record = records_group[0]
        movie = {attribute: first_record[attribute] for attribute in common_movie_attributes}
        movie['locations'] = []
        movie['fun_facts'] = set()
        movie['actors'] = set()
        for record in records_group:
            location = {
                'address':record['locations'],
                'latitude':record['latitude'],
                'longitude':record['longitude'],
            }
            movie['locations'].append(location)
            movie['fun_facts'].add(record['fun_facts'])
            movie['actors'].add(record['actor_1'])
            movie['actors'].add(record['actor_2'])
            movie['actors'].add(record['actor_3'])


        # pprint(movie, width=1)
        movie['fun_facts'] = list(movie['fun_facts'])
        movie['actors'] = list(movie['actors'])
        movies.append(movie)


    output_file = open('Film_Locations_in_San_Francisco.js', 'w+')
    records = json.dumps(records)
    records = 'window.records = %s' % records
    output_file.write(records)
    output_file.write('\n')

    movies = json.dumps(movies)
    movies = 'window.movies = %s' % movies
    output_file.write(movies)