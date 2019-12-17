#!/bin/bash

echo -e '\n\nCreating environment...'
curl -i -X POST \
  http://localhost:8080/environments/ \
  -H 'content-type: text/turtle' \
  -H 'slug: shopfloor' \
  --data-raw '@prefix eve: <http://w3id.org/eve#> .

              <>
                a eve:Environment ;
                eve:contains <http://localhost:8080/workspaces/interactionsWksp> .'

sleep 1

echo -e '\n\nCreating workspace...'
curl -i -X POST \
  http://localhost:8080/workspaces/ \
  -H 'content-type: text/turtle' \
  -H 'slug: interactionsWksp' \
  --data-raw '@prefix eve: <http://w3id.org/eve#> .

              <>
                a eve:Workspace;
                eve:hasName "interactionsWksp";
                eve:contains <http://localhost:8080/artifacts/robot1>;
                eve:contains <http://localhost:8080/artifacts/robot2>.'

echo -e '\n\nCreating robot1 artifact...'
curl -i -X POST \
  http://localhost:8080/artifacts/ \
  -H 'content-type: text/turtle' \
  -H 'slug: robot1' \
  --data-raw '@prefix eve: <http://w3id.org/eve#> .

              <>
                a eve:Artifact ;
                eve:hasName "robot1" ;
                eve:isRobot "robot1" ;
                eve:hasCartagoArtifact "www.Robot1" .'

echo -e '\n\nCreating robot2 artifact...'
curl -i -X POST \
  http://localhost:8080/artifacts/ \
  -H 'content-type: text/turtle' \
  -H 'slug: robot2' \
  --data-raw '@prefix eve: <http://w3id.org/eve#> .

              <>
                a eve:Artifact ;
                eve:hasName "robot2" ;
                eve:isRobot "robot2" ;
                eve:hasCartagoArtifact "www.Robot2" .'