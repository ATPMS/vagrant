#! /usr/bin/env bash
sudo apt-get -y update
sudo apt-get -y dist-upgrade
sudo apt-get -y install postgresql-9.4-postgis-2.1 postgresql-server-dev-9.4 postgresql-client-9.4 golang libedit-dev git libprotobuf-dev protobuf-compiler libncurses5-dev libjsoncpp-dev clang lldb vim rails tmux libcurl4-openssl-dev
sudo apt-get -y install \
    automake \
    autoconf \
    autoconf-archive \
    libtool \
    libdouble-conversion-dev \
    libgoogle-glog-dev \
    libgflags-dev \
    liblz4-dev \
    liblzma-dev \
    libbz2-dev \
    libsnappy-dev \
    zlib1g-dev \
    binutils-dev \
    libjemalloc-dev \
    libssl-dev \
    libsqlite3-dev \
    libiberty-dev \
    libevent-dev \
    unixodbc-dev



cat <<'HERE' | tee -a $HOME/.bash_profile
export CC=clang
export CXX=clang++
export GOPATH=$HOME/.gocode
export EDITOR=vim
export LD_LIBRARY_PATH=/usr/local/lib
HERE

PG_CONF=`sudo -u postgres psql -c "show config_file;" -t -A`
PG_DIR=`dirname $PG_CONF`

cat <<'HERE' | sudo tee -a $PG_DIR/pg_hba.conf
host    all     all     192.168.33.0/24     md5
HERE
sed -r "s/#?listen_addresses.*/listen_addresses = '*'/" $PG_CONF | sudo tee $PG_CONF
sudo systemctl restart postgresql.service

cd ~
mkdir maps
cp -R /vagrant/maps ~

git clone https://github.com/scrosby/OSM-binary
git clone https://github.com/facebook/folly.git -b v0.57.0 --depth 1
wget http://netix.dl.sourceforge.net/project/boost/boost/1.56.0/boost_1_56_0.tar.bz2
wget http://pocoproject.org/releases/poco-1.6.1/poco-1.6.1-all.tar.gz

tar -xvf poco-1.6.1-all.tar.gz
tar -xvf boost_1_56_0.tar.bz2

cd ~/poco-1.6.1-all
./configure --omit=Data/MySQL,Data/ODBC
make && sudo make install

cd ~/boost_1_56_0
sh bootstrap.sh
./b2 && ./b2 install

cd ~/folly/folly
autoreconf -ivf
LIBS='-lboost_system -lboost_thread -lboost_chrono' ./configure --with-boost=/usr/local
make && sudo make install

cd ~/OSM-binary
make -C src
sudo make -C src install

sudo -u postgres createuser trapik -d -s
sudo -u postgres createdb -O trapik trapik

go get github.com/lib/pq

cd /vagrant/trapik-webapp
bundle install
