#!/usr/bin/env python

import boto3

# Return a list of repository objects
def getRepos(client):
  repos = []

  list = client.describe_repositories()

  if 'repositories' in list:
    repos.extend(list['repositories'])

  while list.get('nextToken', None) is not None:
    list = client.describe_repositories(nextToken=list['nextToken'])

    if 'repositories' in list:
      repos.extend(list['repositories'])

  return repos


# Return a list of image ids for a given repo
def getImages(client, repo):
  images = []

  list = client.list_images(repositoryName=repo)

  if "imageIds" in list:
    images.extend(list['imageIds'])

  while list.get('nextToken', None) is not None:
    list = client.list_images(repositoryName=repo, nextToken=list['nextToken'])
    if "imageIds" in list:
      images.extend(list['imageIds'])

  return images


# Main lambda handler
def lambda_handler(event, context):
  client = boto3.client('ecr')

  repos = getRepos(client)

  if len(repos) > 0:
    print ("Found %d repositories"%(len(repos)))

  for r in getRepos(client):
    images = getImages(client, r['repositoryName'])

    # Find all images that do not have a tag
    delete_images = [ img for img in images if "imageTag" not in img ]

    if len(delete_images) > 0:
      print ("Deleting %d untagged images from %s"%(len(delete_images), r['repositoryName']))
      client.batch_delete_image(repositoryName=r['repositoryName'], imageIds=delete_images)

# Shim so we can run locally for testing
if __name__=="__main__":
    lambda_handler(None, None)

