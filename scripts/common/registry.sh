#!/bin/bash -Eu
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

trap error HUP INT QUIT TERM ERR SIGINT SIGQUIT

error() {
  echo "HDFS service registry failed!"
  cleanup
  exit 1
}

usage() {
cat << EOF
usage: $0 (-r service) (-i instance) (-p payload)
       $0 (-u service) [-i instance]
       $0 (-q service) [-c] [-i instance]
       $0 -h
EOF
exit 1
}

parse_args() {
  if [ $# -eq 0 ]; then
    usage;
  fi
  COUNT=
  INSTANCE=
  PAYLOAD=
  QUERY=false
  REGISTER=false
  ROOT=/registry
  UNREGISTER=false
  SERVICE=
  while getopts 'c:r:u:q:hi:p:t:' OPTION; do
    case $OPTION in
      c) COUNT=$OPTARG;;
      h) usage;;
      i) INSTANCE="$OPTARG";;
      p) PAYLOAD="$OPTARG";;
      q) QUERY=true && SERVICE="$OPTARG";;
      r) REGISTER=true && SERVICE="$OPTARG";;
      t) ROOT="$OPTARG";;
      u) UNREGISTER=true && SERVICE="$OPTARG";;
      ?) echo "Invalid argument: -$OPTARG" && usage;;
    esac
  done
}

register() {
  if [ -z "$SERVICE" ] || [ -z "$INSTANCE" ] || [ -z "$PAYLOAD" ]; then
    usage
  fi
  echo $PAYLOAD > $tmp/$INSTANCE
  hdfs dfs -mkdir -p $ROOT/$SERVICE
  hdfs dfs -put -f $tmp/$INSTANCE $ROOT/$SERVICE
}

unregister() {
  if [ -z "$SERVICE" ]; then
    usage
  elif [ -n "$INSTANCE" ]; then
    hdfs dfs -rm $ROOT/$SERVICE/$INSTANCE
  else
    hdfs dfs -rm -r $ROOT/$SERVICE
  fi
}

query() {
  if [ -n "$INSTANCE" ]; then
    hdfs dfs -cat $ROOT/$SERVICE/$INSTANCE
  else
    if [ -n "$COUNT" ]; then
      while [ $(($(hdfs dfs -ls $ROOT/$SERVICE | wc -l) - 1)) -ne $COUNT ]; do
        sleep 3
      done
    fi
    hdfs dfs -get $ROOT/$SERVICE $tmp
    pushd $tmp/$SERVICE > /dev/null
      awk '{ printf "%s\\n", $1 }' *
    popd > /dev/null
  fi
}

cleanup() {
  rm -rf $tmp
}

parse_args "$@"
tmp=/tmp/registry_`cat /dev/urandom | tr -dc '0-9a-zA-Z' | head -c 8`
mkdir -p $tmp
if $REGISTER; then
  register
elif $UNREGISTER; then
  unregister
elif $QUERY; then
  query
fi
cleanup
