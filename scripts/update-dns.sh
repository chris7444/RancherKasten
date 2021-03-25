#!/bin/bash
#
# this will only work in my environment
#
cluster=$(kubectl config current-context)
if [[ $? != 0 ]]
then
  echo please configure KUBECONFIG
  exit 1
fi

domain=k8s.org
dnsserver=${MY_DNS:-'10.5.61.1'}

workernodes=($(kubectl get node -o wide | awk '/\sworker/ {print $6}'))
node=${workernodes[0]}

oldip=$(dig @${dnsserver} *.${cluster}.${domain} +noall +answer | awk '{print $5}')
olddata=""
if [[ "$oldip" != "" ]]
then
  olddata=$(dig @${dnsserver} -x ${oldip} +noall +answer | awk "/*.${cluster}.${domain}/ {print \$5}")
  echo oldip=$oldip olddata=$olddata
fi

ssh ${dnsserver} dnscmd /recorddelete ${domain} *.${cluster} A /f
if [[ "$olddata" != "" ]]
then
  ssh ${dnsserver} dnscmd /recorddelete 78.16.in-addr.arpa ${oldip}.in-addr.arpa PTR /f
fi
ssh ${dnsserver} dnscmd /RecordAdd ${domain} *.${cluster} /createptr A ${node}
#
# Verification
#
dig @${dnsserver} kasten.${cluster}.${domain} +noall +answer
dig @${dnsserver} -x ${node} +noall +answer

