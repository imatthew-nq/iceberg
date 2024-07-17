cd $SPARK_HOME

#Kill all java ps
ps -ef | grep java | grep -v grep | awk '{print $2}' | xargs kill -9

#Start a standalone Spark Master Server

. ./sbin/start-master.sh



#Start a Spark Worker Server
. ./sbin/start-worker.sh spark://$(hostname -f):7077


echo "navigate to http//<host ip address>:8080 in a browser to have view of Spark Master"




