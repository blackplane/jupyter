#!/bin/bash

pg_restore -h localhost --port 56340 -U psqluser -d db --clean --format=custom --verbose ~/Data/postgres/tmp-dump-1run.pg_cust_dump


