#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import re
import sys
import constants

remote_repository_id_list = []

def app_url(content):
  """
  Generate APPLICATION_URL from ENV VAR.
  """
  url = os.environ['APPLICATION_URL']
  return content.replace('$APP_URL', url)

def repository_group(content):
  """
  Generate APPLICATION_URL from ENV VAR.
  """
  group = os.environ['REPOSITORY_GROUP']
  temp = constants.REPOSITORY_GROUP.replace('$ID', group)
  return content.replace('$REPOSITORY_GROUP', temp)

def remote_repositories(content):
  """
  Generate REMOTE_REPOSITORIES from ENV VARs.
  By default Openshift 3 template defines space for 12 REMOTE vars.
  If more needed, aditional var EXTRA_REMOTES is part of the template - use comma as separator.
  """
  global remote_repository_id_list
  temp = '    <remoteRepositories>\n'
  for i in range(12):
    try:
      var_name = os.environ['REMOTE' + str(i+1)]
      if var_name == "":
        continue
      remote_repository = constants.REMOTE_REPOSITORIES.replace('$URL', var_name)
      remote_repository = remote_repository.replace('$REPO_ID', str(i+1))
      remote_repository = remote_repository.replace('$REPO_NAME', str(i+1))
      temp += remote_repository
      remote_repository_id_list.append(i+1)
    except KeyError as e:
      continue
  try:
    extras = os.environ['EXTRA_REMOTES'].split(',')
    if len(extras) == 1:
      temp += '\n    </remoteRepositories>'
      return content.replace('$REMOTE_REPOSITORIES', temp)
    for j in range(len(extras)):
      remote_repository = constants.REMOTE_REPOSITORIES.replace('$URL', str.strip(extras[j]))
      remote_repository = remote_repository.replace('$REPO_ID', str(i+1))
      remote_repository = remote_repository.replace('$REPO_NAME', str(i+1))
      temp += remote_repository
      remote_repository_id_list.append(i+j+2)
  except KeyError as e:
    pass # EXTRA_REMOTES is optional
  temp += '\n    </remoteRepositories>'
  result = content.replace('$REMOTE_REPOSITORIES', temp)
  return result

def proxy_connectors(content):
  """
  Generate PROXY_CONNECTORS from ENV VARs.
  Connect virtual repository group with a real Maven repo.
  """
  global remote_repository_id_list
  temp = '    <proxyConnectors>\n'
  for i in remote_repository_id_list:
    proxy_connector = constants.PROXY_CONNECTORS.replace('$ORDER', str(i))
    proxy_connector = proxy_connector.replace('$TARGET_REPO_ID', str(i))
    temp += proxy_connector
  temp += '\n    </proxyConnectors>'
  result = content.replace('$PROXY_CONNECTORS', temp)
  return result

def main():
  """
  Generate config file for Apache Archiva ($ARCHIVA_HOME/conf/settings.xml)
  Need to use settings.xml distributed with this code.
  """
  settings_file = os.environ['ARCHIVA_HOME'] + '/conf/archiva.xml'
  try:
    with open(settings_file, 'r') as settings:
      content = settings.read()
      content = app_url(content)
      content = repository_group(content)
      content = remote_repositories(content)
      content = proxy_connectors(content)
    with open(settings_file, 'w') as settings:
      settings.write(content)
  except (IOError) as e:
    sys.exit('IOException when operating on file %s' % settings_file)

if __name__ == '__main__':
  main()