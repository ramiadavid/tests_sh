# /etc/profile.d/* execution context ignores shebangs
export TERM_COLORS=`tput colors`
python3 - << EOF  # NOQA

import os
import sys

if not sys.stdout.isatty() or os.path.exists(os.path.expanduser('~/.hushlogin')):
    sys.exit(0)

motd_bw = '''
 _ _ _     _                      _          _____   _               _
| | | |___| |___ ___ _____ ___   | |_ ___   |     |_| |___ ___   ___| |_
| | | | -_| |  _| . |     | -_|  |  _| . |  |  |  | . | . | . |_|_ -|   |
|_____|___|_|___|___|_|_|_|___|  |_| |___|  |_____|___|___|___|_|___|_|_|
'''.lstrip('\n')

motd_color = '''
▄█▀▀█▄ ▀█▀▀█▄ ▄█▀▀█▄ ▄█▀▀█▄    ▄█▀▀██ ▀█▐▌██
██▐▌██ ██▐▌██ ██▐▌██ ██▐▌██    ▀█▄▄▄  ██▄▄██
██  █▄ ██  █▄ ██  █▄ ██  █▄ ▄▄ ▄▄  █▄ ██  ██
 ▀▀▀▀  ▀▀▀▀▀   ▀▀▀▀   ▀▀▀▀  ▀▀ ▀▀▀▀▀  ▀▀  ▀▀
'''  # NOQA

try:
    use_colors = int(os.environ.get('TERM_COLORS', 1)) >= 8
except Exception:
    use_colors = False

context = os.environ.get('PGAPPNAME', '')

motd = motd_color if use_colors else motd_bw
if os.environ.get('JUPYTER_SERVER_ROOT'):
    # Until jupyterlab issue is sorted out
    motd = f'\n<M>{motd_bw}</M>'

dbname = os.environ.get('PGDATABASE', '')
machine = os.environ.get('ODOO_MACHINE', '').replace('-', ' ').capitalize()
stage = os.environ.get('ODOO_STAGE', '')
version = os.environ.get('ODOO_VERSION', '')
version = version.split('.')[0] if version.endswith('.0') else version
warnings = [warn.strip() for warn in os.environ.get('ODOO_WARNINGS', '').splitlines() if warn.strip()]

if stage == 'dev':
    stage = 'development'

motd += f'''
You are connected to your <!>{stage}</!> instance <!>{dbname}</!>
running <!>Odoo {version}</!> on <!>{machine}</!>

<W>Overview of useful commands:</W>

  <W>$</W> <M>odoo-bin shell</M>          Open an Odoo shell
  <W>$</W> <M>odoo-update</M>             Update modules in the database
  <W>$</W> <M>odoosh-import-database</M>  Replace current database and filestore with the provided backup
  <W>$</W> <M>odoo-restart</M>            Restart Odoo service
  <W>$</W> <M>psql</M>                    Open a database shell
'''.rstrip('\n')

if stage != 'production':
    motd += '''
  <W>$</W> <M>mutt</M>                    Check how mails look on text clients (staging and development instances)
'''.rstrip('\n')

# <W>$</W> <M>lnav ~/logs/pg_slow_queries.log</M>    Check slow postgresql queries causing performance issues
motd += '''
  <W>$</W> <M>lnav ~/logs/odoo.log</M>    Navigate in your instance's odoo.log file
'''

if os.environ.get('ODOOSSH'):
    motd += '''
Please note that this SSH connection can be interrupted at any time for maintenance purposes.
'''

ansi_helpers = {
    'g': '\033[90m',        # gray
    'w': '\033[37m',        # white
    'W': '\033[97;1m',      # white bright
    'y': '\033[33m',        # yellow
    'Y': '\033[93m',        # yellow bright
    'm': '\033[35m',        # magenta
    'M': '\033[95m',        # magenta bright
    'r': '\033[31m',        # red
    'R': '\033[91m',        # red bright
    'o': '\033[38:5:166m',  # orange (256)
    'O': '\033[38:5:208m',  # orange bright (256)

    'b': '\033[1m',     # bold
    'u': '\033[4m',     # underline
}
color_by_stage = {
    'production': 'R',
    'staging': 'Y',
    'dummy': 'g',
    'duplicate': 'g',
}
ansi_helpers['!'] = ansi_helpers[color_by_stage.get(stage, 'W')]

if warnings:
    motd += '''\n<u><O><b>/!\ WARNING /!\</b></O></u>\n\n'''
    for warn in warnings:
        motd += f'  <O>{warn}</O>\n'

for name, code in ansi_helpers.items():
    motd = motd.replace('<%s>' % name, code if use_colors else '')
    motd = motd.replace('</%s>' % name, '\033[0m' if use_colors else '')

print(motd)

EOF
# vim:syntax=python