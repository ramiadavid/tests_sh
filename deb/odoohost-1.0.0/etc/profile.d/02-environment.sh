#!/bin/bash
export ADDONS_PATH="/home/odoo/src/odoo/addons,/home/odoo/src/enterprise,/home/odoo/src/themes"

custom_addons="$(find /home/odoo/src/user -name "__manifest__.py" -printf "%h\n" | xargs -I {} dirname {} | sort | uniq | paste -sd ",")"
if [ -n "$custom_addons" ]; then
  export ADDONS_PATH="${ADDONS_PATH},${custom_addons}"
fi

