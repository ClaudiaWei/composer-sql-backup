#!/bin/bash

# exit if any error
set -e

pg_host='' # -h
pg_username='' # -u
pg_password='' # -w
pg_database='' # -d
pg_port='' # -p

while getopts 'h:u:w:d:p:v' flag; do
    case "${flag}" in
        h) pg_host="${OPTARG}" ;;
        u) pg_username="${OPTARG}" ;;
        w) pg_password="${OPTARG}" ;;
        d) pg_database="${OPTARG}" ;;
        p) pg_port="${OPTARG}" ;;
    esac
done

PGPASSWORD="$pg_password" pg_dump -h $pg_host -d $pg_database -U $pg_username -p $pg_port -Fc -f /tmp/db.dmp

ls -la /tmp/db.dmp

gsutil cp /tmp/db.dmp gs://composer_sql_backup/$(date +'%Y/%m/%d')/db.dmp