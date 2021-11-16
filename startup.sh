#!/bin/bash

#export PATH=$SPARK_HOME/bin:$PATH

#$SPARK_HOME/sbin/start-master.sh

jupyter notebook --NotebookApp.token='' \
     --notebook-dir=/home/jupyter/notebooks --ip='*' --port=8888 \
     --no-browser --allow-root

