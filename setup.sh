sudo apt-get install git
sudo apt-get install python-pip
sudo apt-get install libmysqlclient-dev python-dev
sudo apt-get install tmux
sudo apt-get install nginx

#setup elastic serach
cd ~
sudo apt-get update
sudo apt-get install openjdk-7-jre-headless -y
### Check http://www.elasticsearch.org/download/ for latest version of ElasticSearch and replace wget link below
wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.3.2.deb
sudo dpkg -i elasticsearch-1.3.2.deb
sudo service elasticsearch start
curl http://localhost:9200

sudo pip install -r requirements.txt

# load data into elastic serach
cd data
python load_elasticsearch.py

# run server
./run_server

# unitest
./test_runner.sh

