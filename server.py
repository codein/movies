"""
tornado web server
Implement a REST server that returns suggestions and movies
"""

import json
import logging
from operator import itemgetter

from elasticsearch import Elasticsearch
import Levenshtein
import tornado.ioloop
import tornado.web
import tornado.gen

LOG_FORMAT = '%(asctime)s - %(filename)s:%(lineno)s - %(levelname)s - %(message)s'
logging.basicConfig(format=LOG_FORMAT, level=logging.INFO)


class BaseRequestHandler(tornado.web.RequestHandler):
    """Base Handler with capabiblity to write json data back"""

    @property
    def suggestions(self):
        """_suggestions property from the main application object is referenced"""
        if not hasattr(self, '_suggestions'):
            self._suggestions = self.application.suggestions

        return self._suggestions


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
def search(es, query):
    query_body = {
        "query": {
            "fuzzy_like_this": {
                "fields" : ["title"],
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
    '/key/<key>/start/<start>/stop/<stop>' endpoint is served
    Only GET is exposed.
    """

    @tornado.web.asynchronous
    @tornado.gen.coroutine
    def get(self, query):
        """
        return movies for a given query.
        yet to be implemented
        """
        search_results = yield search(self.es, query)
        self.json_write(search_results, 'movies')

class SuggestionRequestHandler(BaseRequestHandler):

    def get(self, query):
        """
        return top 5 suggestions for any given query.
        """
        query = str(query)

        suggestions_distances = []
        for suggestion in self.suggestions:
            suggestions_distance = {
                'suggestion': suggestion,
                'distance': Levenshtein.distance(query, suggestion)
            }

            suggestions_distances.append(suggestions_distance)

        suggestions_distances = sorted(suggestions_distances, key=itemgetter('distance'))
        suggestions_distances = suggestions_distances[:5]
        query_suggestions = [suggestion['suggestion'] for suggestion in suggestions_distances]
        self.json_write(query_suggestions, 'suggestions')

words = '''
["A Jitney Elopement","The Ten Commandments","Greed","The Jazz Singer","Barbary Coast","San Francisco","After the Thin Man","Alexander's Ragtime Band","The Maltese Falcon","Shadow of the Thin Man","Gentleman Jim","Hello Frisco, Hello","Nora Prentiss","Dark Passage","The Lady from Shanghai","I Remember Mama","To the Ends of the Earth","D.O.A","Woman on the Run","All About Eve","The House on Telegraph Hill","Sudden Fear","The Caine Mutiny","It Came From Beneath the Sea","Pal Joey","Vertigo","The Lineup","On the Beach","Midnight Lace","Pleasure of His Company","Susan Slade","Flower Drum Song","Swingin' Along","Experiment in Terror","Birdman of Alcatraz","Days of Wine and Roses","The Birds","Marnie","Point Blank","Guess Who's Coming to Dinner","The Graduate","Bullitt","The Love Bug","Petulia","Yours, Mine and Ours","Psych-Out","Take the Money and Run","They Call Me MISTER Tibbs","Harold and Maude","Dirty Harry","The Organization","What's Up Doc?","The Candidate","Play it Again, Sam","American Graffiti","Magnum Force","The Laughing Policeman","The Conversation","Freebie and the Bean","The Towering Inferno","Herbie Rides Again","Family Plot","The Enforcer","High Crimes","High Anxiety","Invasion of the Body Snatchers","Foul Play","Attack of the Killer Tomatoes","A Night Full of Rain","Superman","Faces of Death","Time After Time","Escape From Alcatraz","Heart Beat","Nine to Five","Serial","Can't Stop the Music","The Competiton","Street Music","Chu Chu and the Philly Flash","Chan is Missing","48 Hours","Star Trek II : The Wrath of Khan","Shoot the Moon","Sudden Impact","The Right Stuff","Thief of Hearts","Crackers","The Times of Harvey Milk","The Woman In Red","Hard to Hold","Jagged Edge","A View to a Kill","Maxie","Star Trek IV: The Voyage Home","Big Touble in Little China","Dim Sum: A Little Bit of Heart","Kamikaze Hearts","Quicksilver","Burglar","Innerspace","The Dead Pool","The Presidio","The Last of the Gladiators","Beaches","Tucker: The Man and His Dreams","Patty Hearst","True Believer","Fat Man and Little Boy","Common Threads: Stories From the Quilt","Casualties of War","Indiana Jones and the Last Crusade","Pacific Heights","Another 48 Hours","Pretty Woman","Vegas in Space","The Doors","Class Action","Shattered","Dying Young","The Doctor","Star Trek VI: The Undiscovered County","Until the End of the World","Basic Instinct","Raising Cain","Final Analysis","Sneakers","Memoirs of an Invisible Man","Sister Act","Joy Luck Club","Sister Act 2: Back in the Habit","Mrs. Doubtfire","So I Married an Axe Murderer","The Nightmare Before Christmas","Fearless","Getting Even with Dad","Heart and Souls","Interview With The Vampire","Golden Gate","Junior","Forrest Gump","Nina Takes a Lover","When a Man Loves a Woman","Murder in the First","The Net","Jade","Nine Months","Panther","Copycat","The Rock","Tin Cup","The Fan","Jack","Phenomenon","James and the Giant Peach","Mother","Down Periscope","Happy Gilmore","Homeward Bound II: Lost in San Francisco","The Game","A Smile Like Yours ","George of the Jungle","Metro","Dream with the Fishes","Fathers' Day","A Smile Like Yours","Flubber","Desperate Measures","Doctor Doolittle","Dream for an Insomniac","City of Angels","Patch Adams","What Dreams May Come","Around the Fire","How Stella Got Her Groove Back","Sphere","The Parent Trap","Edtv","Seven Girlfriends","The Bachelor","Stigmata","The Other Sister","Bicentennial Man","The Matrix","Boys and Girls","Bedazzled","Groove","Just One Night","Live Nude Girls Unite","Playing Mona Lisa","Romeo Must Die","Sausalito","Woman on Top","The Wedding Planner","Sweet November","Dr. Doolittle 2","By Hook or By Crook","Serendipity","Haiku Tunnel","The Princess Diaries","Mission (aka City of Bars)","Never Die Twice","Rollerball","Cherish","The Sweetest Thing","Forty Days and Forty Nights","Under the Tuscan Sun","Swing","The Fog of War","Confessions of a Burning Man","Dopamine","The Core","Mona Lisa Smile","House of Sand and Fog","Hulk","Julie and Jack","Twisted","Fandom","Red Diaper Baby","What the Bleep Do We Know","American Yearbook","50 First Dates","The Assassination of Richard Nixon","Tweek City","24 Hours on Craigslist","Night of Henna","Rent","Just Like Heaven","Bee Season","The Zodiac","The Californians","The Bridge","The Pursuit of Happyness","Zodiac","Milk","Hereafter","On the Road","God is a Communist?* (show me heart universe)","Broken-A Modern Love Story ","Babies","Love & Taxes","180","My Reality","I's","Hemingway & Gelhorn","CSI: NY- episode 903","Alcatraz","The Master","Knife Fight","Big Sur","Blue Jasmine","Red Widow","The Internship","Quitters","Big Eyes","Looking","Godzilla","Need For Speed","Parks and Recreation","Dawn of the Planet of the Apes","About a Boy","The Diary of a Teenage Girl"]
'''

class App(tornado.web.Application):
    """Main app suggestions singleton is an attribute of this object."""
    handlers = [
        (r"/movies/*([a-zA-Z0-9-]*)", MovieRequestHandler),
        (r"/suggest/*([a-zA-Z0-9-]*)", SuggestionRequestHandler),
        (r'/static/(.*)', tornado.web.StaticFileHandler, {'path': './'}),
    ]

    def __init__(self):
        tornado.web.Application.__init__(self, self.handlers, debug=True)

    @property
    def suggestions(self):
        """intantiates the list of suggestions."""
        if not hasattr(self, '_suggestions'):
            suggestions = [str(word).lower() for word in json.loads(words)]
            self._suggestions = suggestions

        return self._suggestions

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

