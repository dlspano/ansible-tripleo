#!/usr/bin/env python
import argparse
import logging
import os
import sys
from openstack import connection

LOG = logging.getLogger(__name__)

# Service and its corresponding openstack sdk generator
SERVICES = {'image': 'images',
            'compute': 'servers'}


def get_credentials():
    """
    This function retrieves openstack credentials from
    the calling user's bash environment.
    :return: creds
    """
    creds = {}
    creds['username'] = os.environ['OS_USERNAME']
    creds['password'] = os.environ['OS_PASSWORD']
    creds['auth_url'] = os.environ['OS_AUTH_URL']
    creds['project_name'] = os.environ['OS_TENANT_NAME']
    return creds


def check_assets(conn, service, list_method):
    """
    This function takes in a service name and a list method
    to check to see if there are any objects.
    The list method corresponds to the classes to what's found
    in the Openstack SDK API
    CLI equivalent:
        openstack image list
        openstack server list

    :param conn:
    :param service:
    :param list_method:
    :return: count
    """
    count = 0
    service_interface = getattr(conn, service)
    service_list = getattr(service_interface, list_method)
    for asset in service_list():
        count += 1
        LOG.info('Asset {0} Name {1}'.format(list_method, asset.name))
    LOG.info('Count is {0}'.format(count))
    return count


def main():
    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument(
        '-v', '--verbose', action='count', default=0,
        help="Increase verbosity (specify multiple times for more)")
    parser.add_argument(
        '-s', '--service', action='store', choices=['image', 'compute'],
        default='image', help="Specify a service to check")
    args = parser.parse_args()

    log_level = logging.INFO
    if args.verbose >= 1:
        log_level = logging.DEBUG

    format = '%(asctime)s - %(levelname)s - %(message)s'
    logging.basicConfig(format=format, datefmt='%m-%d %H:%M', level=log_level)
    credentials = get_credentials()
    conn = connection.Connection(**credentials)
    list_method = SERVICES[args.service]
    exit_code = 0
    is_installed = (check_assets(conn, args.service, list_method))
    if is_installed:
        exit_code = 1
    sys.exit(exit_code)

if __name__ == '__main__':
    main()
