## SF Movies
Offline version hosted at http://codein.github.io/movies/

Checkout a demo video at https://github.com/codein/movies/blob/master/output.mkv

### Overview

This impementation is a Full-stack implementation: include both front-end and back-end.


#### Data-Enginnering
* This step is performed using data/data_engineering.py
* Firstly, .csv data fetched from data.sfgov.org had to supported with geo-location data.
* Secondly, records where grouped into movie objects with these common attributes ('title','release year','production_company','distributor','director','writer')
* Finally this data is written into a .js file, so that it can be easily used in a browser.

#### Front-end
* Implemented using angularjs and twitter bootstrap, theme courtesy goes to www.bootply.com
* The browser just loads the data from previous step in scripts
* The front end was designed to operate in a offline and online mode.
* In offline mode filtering is performed in browser, while in online this can be off loaded to server.
* offline version is hosted at http://codein.github.io/movies/

#### API Server
* The back end server is implemented as a tornado API server.
* Firstly, the server is used to server the static assets for the app at /static/*
* Secondly, serves /suggestion/<query> for a given user query.
* Finally, /movies/<query> end point serves movies for a given user query.

#### commands
* start API server
```
./run_server
```

* run unitest
```
./test_runner.sh
```




