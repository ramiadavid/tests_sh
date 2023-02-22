#!/bin/bash
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/bin"
export PGPASSWORD="toBe72/*"
export PGUSER="odoo"
export PGDATABASE="processcontrol"
export PGHOST="localhost"
export TZ="Europe/Madrid"
export LANG="C.UTF-8"
export ADDONS_PATH="/home/odoo/src/odoo/addons,/home/odoo/src/enterprise,/home/odoo/src/themes,$(find /home/odoo/src/user -name "__manifest__.py" -printf "%h\n" | xargs -I {} dirname {} | sort | uniq | paste -sd ",")"

