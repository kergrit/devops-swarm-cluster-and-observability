#!/bin/bash

# list swarm node id
docker node ls

# find service node-exporter ip
docker service ps --filter desired-state=running --format "{{.ID}} {{.Name}}" monitoring_node-exporter | while read id name ignore ; do echo "$name $(docker inspect --format '{{range $conf := (index (index .NetworksAttachments))}}{{.Addresses}}{{end}}' $id)"; done

# find service cadvisor ip
docker service ps --filter desired-state=running --format "{{.ID}} {{.Name}}" monitoring_cadvisor | while read id name ignore ; do echo "$name $(docker inspect --format '{{range $conf := (index (index .NetworksAttachments))}}{{.Addresses}}{{end}}' $id)"; done

