#!/bin/bash
#author: lee
ENV_HOME="`dirname \`readlink -f $0\``"
PYTHON_VERSION="python27"
TAR_DIR="${ENV_HOME}/tar"
CONF_DIR="${ENV_HOME}/conf"
BIN_DIR="${ENV_HOME}/bin"
NGINX_HOME="/usr/local/nginx"
SPAWN_FCGI_HOME="/usr/local/spawn-fcgi"
PYTHON_HOME="/usr/local/${PYTHON_VERSION}"

error() {
  echo -e "\e[31m*** "ERROR:" $1\e[0m" >&2
  exit 1
}

warn() {
  echo -e "\e[33m*** "WARN:" $1\e[0m" >&2
}

check(){
    if [ $? -ne 0 ];then
        error 'Check filed.'
    else
        warn 'Check success.'
}


#Part 1
#install dependency
ins_dep(){
    yum install gcc gcc-c++
}
#install python
ins_py(){
cd ${TAR_DIR}
    tar zxf Python-2.7.11.tgz
    cd Python-2.7.11 && ./conf
    make && make install
    if [ -f ${PYTHON_HOME}/bin/python2 ];then
        ln -s ${PYTHON_HOME}/bin/python2 /usr/bin/${PYTHON_VERSION}
    else
        echo "****ERROR: NO ${PYTHON_HOME}/bin/python2."
    fi
}

#install pip
ins_pip(){
    cd ${TAR_DIR}
    ${PYTHON_VERSION} get-pip.py
    check
    warn "Install pip success."
}

#install setuptools
ins_setuptools(){
    cd ${TAR_DIR}
    tar zxf setuptools.tar.gz 
    cd setuptools 
    ${PYTHON_VERSION} setup.py install
    check
    warn "Install setuptools success."
}
#install pcre
ins_pcre(){
    cd ${TAR_DIR}
    tar zxf pcre-8.38.tar.gz 
    cd pcre-8.38 
    ./configure 
    make && make install
    find / -type f -name *libpcre.so.*  | grep -q libpcre.so.0.0.1
    check
    #Need by nginx
    ln -s /lib64/libpcre.so.0.0.1  /lib64/libpcre.so.1
    warn "Install pcre success."
}
#install ipython

#install webpy
ins_webpy(){ 
    cd ${TAR_DIR} 
    tar zxf web.tar.gz 
    cd webpy 
    ${PYTHON_VERSION} setup.py install
    check 
    warn "Install webpy success."
}

#install mysqldb

ins_mysqldb(){ 
    cd ${TAR_DIR} 
    tar zxf MySQL-python-1.2.3c1.tar.gz 
    cd MySQL-python-1.2.3c1
    ${PYTHON_VERSION} setup.py install
    check 
    warn "Install mysqldb success."
}


#install spawn-fcgi

ins_spawnfcgi(){ 
    cd ${TAR_DIR} 
    tar zxf spawn-fcgi-1.6.4.tar.gz
    cd spawn-fcgi-1.6.4
    ./configure --prefix=${SPAWN_FCGI_HOME}
    make && make install
    
    check 
    
    warn "Install spawn-fcgi success."
}
#insstall flup

ins_flup(){ 
    cd ${TAR_DIR} 
    tar zxf flup-1.0.tar.gz
    cd flup-1.0
    ${PYTHON_VERSION} setup.py install
    check 
    warn "Install flug success."

#install nginx

ins_nginx(){ 
    cd ${TAR_DIR} 
    tar zxf nginx-1.9.9.tar.gz
    cd nginx-1.9.9
    ./configure --prefix=${NGINX_HOME}
    make && make install
    check 
    cd ${ENV_HOME}
    mkdir -p ${NGINX_HOME}/bin
    cp -av bin/nginx_control ${NGINX_HOME}/bin
    cd ${NGINX_HOME}/conf && mv nginx.conf nginx.conf.default
    cp -av ${ENV_HOME}/conf/nginx.conf ${NGINX_HOME}/conf
    warn "Install nginx success."
}

main(){
    ins_dep
    ins_pip
    ins_setuptools
    ins_pcre
    ins_webpy
    ins_mysqldb
    ins_spawnfcgi
    ins_flup
    ins_nginx
}

main
