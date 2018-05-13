#!/bin/bash

TMP_FOLDER=$(mktemp -d)
CONFIG_FILE='Linda.conf'
CONFIGFOLDER='/root/.Linda'
COIN_DAEMON='Lindad'
COIN_CLI='Lindad'
COIN_PATH='/usr/local/bin/'
COIN_TGZ='https://github.com/Lindacoin/Linda/releases/download/2.0.0.1/Unix.Lindad.v2.0.0.1g.tar.gz'
COIN_ZIP=$(echo $COIN_TGZ | awk -F'/' '{print $NF}')
COIN_NAME='Linda'
COIN_PORT=33820
RPC_PORT=33821

NODEIP=$(curl -s4 icanhazip.com)


RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'


function download_node() {
  echo -e "Prepare to download ${GREEN}$COIN_NAME${NC}."
  cd $TMP_FOLDER >/dev/null 2>&1
  wget -q $COIN_TGZ
  compile_error
  tar xvzf $COIN_ZIP -C $COIN_PATH >/dev/null 2>&1
  cd - >/dev/null 2>&1
  rm -rf $TMP_FOLDER >/dev/null 2>&1
  clear
}


function configure_systemd() {
  cat << EOF > /etc/systemd/system/$COIN_NAME.service
[Unit]
Description=$COIN_NAME service
After=network.target

[Service]
User=root
Group=root

Type=forking
#PIDFile=$CONFIGFOLDER/$COIN_NAME.pid

ExecStart=$COIN_PATH$COIN_DAEMON -daemon -conf=$CONFIGFOLDER/$CONFIG_FILE -datadir=$CONFIGFOLDER
ExecStop=-$COIN_PATH$COIN_CLI -conf=$CONFIGFOLDER/$CONFIG_FILE -datadir=$CONFIGFOLDER stop

Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  sleep 3
  systemctl start $COIN_NAME.service
  systemctl enable $COIN_NAME.service >/dev/null 2>&1

  if [[ -z "$(ps axo cmd:100 | egrep $COIN_DAEMON)" ]]; then
    echo -e "${RED}$COIN_NAME is not running${NC}, please investigate. You should start by running the following commands as root:"
    echo -e "${GREEN}systemctl start $COIN_NAME.service"
    echo -e "systemctl status $COIN_NAME.service"
    echo -e "less /var/log/syslog${NC}"
    exit 1
  fi
}


function create_config() {
  mkdir $CONFIGFOLDER >/dev/null 2>&1
  RPCUSER=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w10 | head -n1)
  RPCPASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w22 | head -n1)
  cat << EOF > $CONFIGFOLDER/$CONFIG_FILE
rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
rpcport=$RPC_PORT
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
port=$COIN_PORT
EOF
}

function create_key() {
  echo -e "Enter your ${RED}$COIN_NAME Masternode Private Key${NC}. Leave it blank to generate a new ${RED}Masternode Private Key${NC} for you:"
  read -e COINKEY
  if [[ -z "$COINKEY" ]]; then
  $COIN_PATH$COIN_DAEMON -daemon
  sleep 30
  if [ -z "$(ps axo cmd:100 | grep $COIN_DAEMON)" ]; then
   echo -e "${RED}$COIN_NAME server couldn not start. Check /var/log/syslog for errors.{$NC}"
   exit 1
  fi
  COINKEY=$($COIN_PATH$COIN_CLI masternode genkey)
  if [ "$?" -gt "0" ];
    then
    echo -e "${RED}Wallet not fully loaded. Let us wait and try again to generate the Private Key${NC}"
    sleep 30
    COINKEY=$($COIN_PATH$COIN_CLI masternode genkey)
  fi
  $COIN_PATH$COIN_CLI stop
fi
clear
}

function update_config() {
  sed -i 's/daemon=1/daemon=0/' $CONFIGFOLDER/$CONFIG_FILE
  cat << EOF >> $CONFIGFOLDER/$CONFIG_FILE
logintimestamps=1
maxconnections=256
#bind=$NODEIP
masternode=1
externalip=$NODEIP:$COIN_PORT
masternodeprivkey=$COINKEY
addnode=107.191.41.54
addnode=178.25.217.181
addnode=209.250.247.62
addnode=208.69.150.23
addnode=45.77.145.99
addnode=45.63.98.89
addnode=207.246.84.108
addnode=140.82.59.37
addnode=208.69.150.21
addnode=207.246.116.234
addnode=108.61.214.16
addnode=144.202.54.150
addnode=140.82.44.77
addnode=144.202.107.3
addnode=144.202.81.28
addnode=178.27.96.76
addnode=107.191.40.51
addnode=45.63.99.162
addnode=209.250.248.224
addnode=45.77.138.142
addnode=45.32.26.76
addnode=125.236.242.30
addnode=45.77.152.116
addnode=144.202.24.242
addnode=45.76.153.150
addnode=208.69.150.58
addnode=80.211.179.117
addnode=104.238.134.82
addnode=139.162.180.106
addnode=208.167.242.195
addnode=207.246.122.244
addnode=140.82.2.71
addnode=45.63.99.107
addnode=209.250.241.2
addnode=45.76.117.131
addnode=198.13.35.104
addnode=108.61.218.113
addnode=159.89.109.209
addnode=45.63.31.244
addnode=148.251.183.38
addnode=45.76.250.5
addnode=51.15.195.84
addnode=207.148.28.123
addnode=88.99.68.228
addnode=45.32.231.49
addnode=77.72.149.117
addnode=8.9.37.139
addnode=45.63.2.141
addnode=209.250.246.221
addnode=144.217.87.98
addnode=140.82.44.20
addnode=207.246.109.211
addnode=62.195.125.111
addnode=209.250.249.48
addnode=207.148.87.39
addnode=104.156.225.135
addnode=140.82.45.151
addnode=144.202.62.223
addnode=45.63.53.130
addnode=108.18.222.85
addnode=108.61.149.210
addnode=45.32.213.179
addnode=91.47.16.107
addnode=173.255.206.204
addnode=91.134.245.121
addnode=108.61.142.13
addnode=78.47.114.206
addnode=54.245.212.64
addnode=140.82.41.252
addnode=88.198.48.153
addnode=167.99.174.146
addnode=195.201.216.219
addnode=209.250.241.103
addnode=45.77.136.103
addnode=188.166.105.106
addnode=45.32.177.186
addnode=62.138.3.224
addnode=78.70.234.88
addnode=66.70.138.81
addnode=199.247.24.43
addnode=108.61.23.37
addnode=149.172.147.240
addnode=98.242.26.248
addnode=104.207.143.0
addnode=209.250.246.153
addnode=149.210.171.120
addnode=188.165.167.125
addnode=54.37.241.241
addnode=45.77.85.205
addnode=170.250.126.142
addnode=45.63.5.73
addnode=208.167.245.83
addnode=54.36.234.94
addnode=207.148.29.184
addnode=66.70.138.114
addnode=145.239.46.102
addnode=54.36.234.101
addnode=41.162.83.35
addnode=31.31.78.135
addnode=54.38.132.176
addnode=54.37.238.217
addnode=50.101.42.206
addnode=45.76.219.254
addnode=104.1.255.44
addnode=149.28.113.63
addnode=45.77.140.49
addnode=54.36.71.112
addnode=178.79.181.84
addnode=144.202.61.73
addnode=207.148.64.65
addnode=8.9.5.50
addnode=140.82.45.4
addnode=45.76.219.193
addnode=207.246.104.201
addnode=54.36.234.114
addnode=80.211.30.124
addnode=54.36.234.103
addnode=45.77.245.32
addnode=144.202.76.28
addnode=51.143.153.135
addnode=108.61.168.153
addnode=142.44.194.179
addnode=217.182.208.63
addnode=207.148.4.73
addnode=188.63.135.124
addnode=78.42.100.102
addnode=54.37.111.88
addnode=213.22.78.239
addnode=89.31.96.21
addnode=93.6.61.19
addnode=143.176.254.63
addnode=54.37.238.220
addnode=149.28.128.73
addnode=54.37.238.228
addnode=108.61.145.206
addnode=66.199.72.22
addnode=207.246.115.21
addnode=140.82.49.16
addnode=185.233.105.123
addnode=80.229.17.246
addnode=114.198.78.193
addnode=108.61.166.92
addnode=149.28.39.86
addnode=69.64.33.37
addnode=8.12.16.179
addnode=5.189.186.94
addnode=84.23.220.90
addnode=172.126.33.80
addnode=54.36.71.188
addnode=144.202.22.234
addnode=209.250.255.18
addnode=80.211.179.95
addnode=109.168.108.130
addnode=45.77.189.17
addnode=108.89.154.125
addnode=13.90.231.78
addnode=45.76.143.111
addnode=45.77.166.39
addnode=91.20.71.31
addnode=207.148.19.27
addnode=144.202.14.150
addnode=54.175.209.79
addnode=62.215.84.31
addnode=73.121.249.181
addnode=87.103.195.244
addnode=42.188.246.190
addnode=54.38.132.189
addnode=46.163.166.50
addnode=92.97.146.239
addnode=5.9.91.179
addnode=94.62.231.45
addnode=67.243.174.29
addnode=86.186.176.90
addnode=84.27.15.27
addnode=85.214.55.215
addnode=54.38.132.138
addnode=188.165.218.169
addnode=65.129.108.233
addnode=54.37.238.32
addnode=104.207.155.165
addnode=54.37.111.114
addnode=31.14.131.137
addnode=45.76.23.109
addnode=165.73.110.56
addnode=66.70.138.86
addnode=79.129.175.45
addnode=96.252.125.93
addnode=86.169.150.72
addnode=70.114.145.243
addnode=115.64.98.76
addnode=46.172.154.104
addnode=84.84.117.253
addnode=163.172.160.212
addnode=199.247.26.173
addnode=8.12.18.10
addnode=8.9.30.35
addnode=45.24.48.164
addnode=80.217.62.14
addnode=68.227.227.150
addnode=208.69.150.20
addnode=207.148.95.253
addnode=108.195.193.89
addnode=78.134.102.185
addnode=91.138.249.195
addnode=47.93.161.68
addnode=121.121.119.121
addnode=180.183.184.181
addnode=107.191.42.179
addnode=72.238.137.220
addnode=45.48.88.140
addnode=2.154.238.172
addnode=207.148.117.83
addnode=35.201.155.20
addnode=83.162.131.199
addnode=219.131.122.233
addnode=108.61.156.18
addnode=174.230.161.208
addnode=99.47.45.108
addnode=71.56.73.26
addnode=199.247.29.23
addnode=172.245.80.39
addnode=151.49.24.201
addnode=109.181.234.71
addnode=62.103.217.96
addnode=62.232.139.70
addnode=178.62.74.214
addnode=77.58.52.185
addnode=89.212.194.216
addnode=172.245.80.62
addnode=47.187.254.193
addnode=72.188.235.21
addnode=69.137.53.128
addnode=72.46.57.26
addnode=31.10.154.118
addnode=108.252.68.144
addnode=149.28.34.131
addnode=178.248.80.34
addnode=92.111.168.31
addnode=73.148.12.226
addnode=188.153.64.17
addnode=89.102.85.129
addnode=173.63.29.170
addnode=91.37.144.252
addnode=80.61.199.191
addnode=73.198.232.121
addnode=45.63.18.179
addnode=104.207.138.87
addnode=66.108.157.20
addnode=54.36.71.162
addnode=185.141.61.190
addnode=24.21.74.154
addnode=5.39.184.79
addnode=35.194.198.246
addnode=31.34.17.248
addnode=158.69.5.16
addnode=113.103.7.154
EOF
}


function enable_firewall() {
  echo -e "Installing and setting up firewall to allow ingress on port ${GREEN}$COIN_PORT${NC}"
  ufw allow $COIN_PORT/tcp comment "$COIN_NAME MN port" >/dev/null
  ufw allow ssh comment "SSH" >/dev/null 2>&1
  ufw limit ssh/tcp >/dev/null 2>&1
  ufw default allow outgoing >/dev/null 2>&1
  echo "y" | ufw enable >/dev/null 2>&1
}


function get_ip() {
  declare -a NODE_IPS
  for ips in $(netstat -i | awk '!/Kernel|Iface|lo/ {print $1," "}')
  do
    NODE_IPS+=($(curl --interface $ips --connect-timeout 2 -s4 icanhazip.com))
  done

  if [ ${#NODE_IPS[@]} -gt 1 ]
    then
      echo -e "${GREEN}More than one IP. Please type 0 to use the first IP, 1 for the second and so on...${NC}"
      INDEX=0
      for ip in "${NODE_IPS[@]}"
      do
        echo ${INDEX} $ip
        let INDEX=${INDEX}+1
      done
      read -e choose_ip
      NODEIP=${NODE_IPS[$choose_ip]}
  else
    NODEIP=${NODE_IPS[0]}
  fi
}


function compile_error() {
if [ "$?" -gt "0" ];
 then
  echo -e "${RED}Failed to compile $COIN_NAME. Please investigate.${NC}"
  exit 1
fi
}


function checks() {
if [[ $(lsb_release -d) != *16.04* ]]; then
  echo -e "${RED}You are not running Ubuntu 16.04. Installation is cancelled.${NC}"
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}$0 must be run as root.${NC}"
   exit 1
fi

if [ -n "$(pidof $COIN_DAEMON)" ] || [ -e "$COIN_DAEMOM" ] ; then
  echo -e "${RED}$COIN_NAME is already installed.${NC}"
  exit 1
fi
}

function prepare_system() {
echo -e "Prepare the system to install ${GREEN}$COIN_NAME${NC} master node."
apt-get update >/dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get update > /dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y -qq upgrade >/dev/null 2>&1
apt install -y software-properties-common >/dev/null 2>&1
echo -e "${GREEN}Adding bitcoin PPA repository"
apt-add-repository -y ppa:bitcoin/bitcoin >/dev/null 2>&1
echo -e "Installing required packages, it may take some time to finish.${NC}"
apt-get update >/dev/null 2>&1
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" make software-properties-common \
build-essential libtool autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev libboost-program-options-dev \
libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git wget curl libdb4.8-dev bsdmainutils libdb4.8++-dev \
libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev  libdb5.3++ unzip libzmq5 >/dev/null 2>&1
if [ "$?" -gt "0" ];
  then
    echo -e "${RED}Not all required packages were installed properly. Try to install them manually by running the following commands:${NC}\n"
    echo "apt-get update"
    echo "apt -y install software-properties-common"
    echo "apt-add-repository -y ppa:bitcoin/bitcoin"
    echo "apt-get update"
    echo "apt install -y make build-essential libtool software-properties-common autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev \
libboost-program-options-dev libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git curl libdb4.8-dev \
bsdmainutils libdb4.8++-dev libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev libdb5.3++ unzip libzmq5"
 exit 1
fi
clear
}

function important_information() {
 echo -e "================================================================================================================================"
 echo -e "$COIN_NAME Masternode is up and running listening on port ${RED}$COIN_PORT${NC}."
 echo -e "Configuration file is: ${RED}$CONFIGFOLDER/$CONFIG_FILE${NC}"
 echo -e "Start: ${RED}systemctl start $COIN_NAME.service${NC}"
 echo -e "Stop: ${RED}systemctl stop $COIN_NAME.service${NC}"
 echo -e "VPS_IP:PORT ${RED}$NODEIP:$COIN_PORT${NC}"
 echo -e "MASTERNODE PRIVATEKEY is: ${RED}$COINKEY${NC}"
 echo -e "Please check ${RED}$COIN_NAME${NC} daemon is running with the following command: ${RED}systemctl status $COIN_NAME.service${NC}"
 echo -e "Use ${RED}$COIN_CLI masternode status${NC} to check your MN."
 if [[ -n $SENTINEL_REPO  ]]; then
  echo -e "${RED}Sentinel${NC} is installed in ${RED}$CONFIGFOLDER/sentinel${NC}"
  echo -e "Sentinel logs is: ${RED}$CONFIGFOLDER/sentinel.log${NC}"
 fi
 echo -e "================================================================================================================================"
}

function setup_node() {
  get_ip
  create_config
  create_key
  update_config
  enable_firewall
  important_information
  configure_systemd
}


##### Main #####
clear

checks
prepare_system
download_node
setup_node

