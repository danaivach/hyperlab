#!/bin/bash

echo -e '\n\nCreating environment...'
curl -i -X POST \
  http://localhost:8080/environments/ \
  -H 'content-type: text/turtle' \
  -H 'slug: shopfloor' \
  -d '@payload/0_env_payload.ttl'

sleep 1

echo -e '\n\nCreating workspace...'
curl -i -X POST \
  http://localhost:8080/workspaces/ \
  -H 'content-type: text/turtle' \
  -H 'slug: interactionsWksp' \
  -d '@payload/1_wksp_payload.ttl'

echo -e '\n\nCreating robot1 artifact...'
curl -i -X POST \
  http://localhost:8080/artifacts/ \
  -H 'content-type: text/turtle' \
  -H 'slug: robot1' \
  -d '@payload/2_robot1_payload.ttl'

echo -e '\n\nCreating robot2 artifact...'
curl -i -X POST \
  http://localhost:8080/artifacts/ \
  -H 'content-type: text/turtle' \
  -H 'slug: robot2' \
  -d '@payload/3_robot2_payload.ttl'
  
  echo -e '\n\nCreating robot3 artifact...'
curl -i -X POST \
  http://localhost:8080/artifacts/ \
  -H 'content-type: text/turtle' \
  -H 'slug: robot3' \
  -d '@payload/4_robot3_payload.ttl'
  
  echo -e '\n\nCreating manual ...'
curl -i -X POST \
  http://localhost:8080/manuals/ \
  -H 'content-type: text/turtle' \
  -H 'slug: phantomXmanual' \
  -d '@payload/5_manual_payload.ttl'
