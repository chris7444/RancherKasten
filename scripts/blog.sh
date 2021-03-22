#!/bin/bash
#
# Submit a post in the production cluster
#   prereq: need to install the basic auth plugin in wordpress
#   and the user used in the curl command below
#
content=$(mktemp)
cat <<EOF >${content}
{
  "title": "HPE Nimble and Kasten",
  "content": "Hello, this is my daily post created $(date)",
  "status": "publish"
}
EOF
curl \
     --user chris:foo \
     --header "Accept: application/json" -H "Content-Type: application/json" \
     -X POST \
     http://wordpress.prod.k8s.org/wp-json/wp/v2/posts \
     --data-binary @${content} 
unlink ${content}``
