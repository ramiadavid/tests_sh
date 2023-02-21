import os


def get_odoo_args(args):
    odoo_args = [
        '--addons-path', os.environ['ADDONS_PATH'],
        '--unaccent',
        '--no-database-list',
        '--proxy-mode',
        '--db_host', os.environ['PGHOST'],
        '--db_port=5432',
        '--db-filter=',
        '--data-dir', '/home/odoo/data',
        '--config', '/home/odoo/.config/odoo/odoo.conf',
        '--workers=0',
    ]
    if not any(arg.startswith('--database') for arg in args):
        odoo_args.extend(['--database', os.environ['PGDATABASE']])
    if not any(arg.startswith('--db_maxconn') for arg in args):
        odoo_args.append('--db_maxconn=16')
    if not any(arg.startswith('--without-demo') for arg in args) and os.environ['ODOO_STAGE'] != 'dev':
        odoo_args.append('--without-demo=all')
    return args + odoo_args
