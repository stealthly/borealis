borealis
========

Apache Aurora scripts for Open Source Projects

# Dependencies
* curl - Required. The cURL command line tool and an active network connection is required to download distributions.
* hdfs - Required. It is assumed that HDFS command line tool is accessible on your target machine, and that permissions have been granted for the /registry folder.
* gpg - Optional. If present, all distributions will undergo signature verification before execution may occur. No automated entrance into the Apache Web Of Trust is implemented. It is the responsibility of the end user to do this. For more information, see: http://www.apache.org/dev/openpgp.html#wot
* md5sum - Optional. Used to verify distributions.
* sha1sum - Optional. Used to verify distributions.

# Starting components
```shell
aurora create Oscar/$USER/devel/zookeeper scripts/zookeeper.aurora
aurora create Oscar/$USER/devel/kafka scripts/kafka.aurora
```

# Stopping components
```shell
aurora killall Oscar/$USER/devel/kafka scripts/kafka.aurora
aurora killall Oscar/$USER/devel/zookeeper scripts/zookeeper.aurora
```