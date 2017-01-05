#! /bin/bash

#
# jumpcloud-cleanup     Run commands at system shutdown.
#
# chkconfig: 01 95 05
#
### BEGIN INIT INFO
# Provides: jumpcloud-cleanup
# Required-Start: $network $syslog
# Required-Stop:
# Default-Start: 5
# Default-Stop: 0
# Short-Description: instance shutdown
# Description: Run commands at system shutdown.
### END INIT INFO
#

######################################################################################
# adapted from examples provided at https://github.com/TheJumpCloud/SystemContextAPI #
######################################################################################

case "$1" in
  start)
    touch /var/lock/subsys/jumpcloud-cleanup
    exit 0
    ;;

  stop)

    ##
    ## Example of moving a system to the "stopped instances" tag upon system shut down.
    ##
    ## Replace the following with any System Context Api call upon shutdown.
    ## System Context Api Docs: https://github.com/TheJumpCloud/SystemContextAPI
    ##
    conf="`cat /opt/jc/jcagent.conf`"
    regex="systemKey\":\"(\w+)\""

    if [[ $conf =~ $regex ]] ; then
      systemKey="${BASH_REMATCH[1]}"
    fi

    now=`date -u "+%a, %d %h %Y %H:%M:%S GMT"`;

    ### to delete an instance on shutdown
    signstr="DELETE /api/systems/${systemKey} HTTP/1.1\ndate: ${now}"
    signature=`printf "$signstr" | openssl dgst -sha256 -sign /opt/jc/client.key | openssl enc -e -a | tr -d '\n'` ;
    curl -iq \
      -X "DELETE" \
      -H "Date: ${now}" \
      -H "Authorization: Signature keyId=\"system/${systemKey}\",headers=\"request-line date\",algorithm=\"rsa-sha256\",signature=\"${signature}\"" \
      --url https://console.jumpcloud.com/api/systems/${systemKey}

    rm -f /var/lock/subsys/jumpcloud-cleanup
    ;;

  *)
    exit 0
    ;;

esac
