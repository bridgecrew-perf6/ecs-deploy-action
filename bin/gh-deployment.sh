#!/usr/bin/env bash

set -e

owner="pathstream"
repo="insert-name"
aws_region="us-west-2"
staging_cluster="QA2"
production_cluster="prod2"
sha=$(git show --format="%H" --no-patch)

token=$1
environment=$2

api_prefix=https://api.github.com/repos/${owner}/${repo}/
ant_man_preview="application/vnd.github.ant-man-preview+json"

if [ "$3" == "create" ]; then
    # N.B. We always set transient and production environment to false to
    # ensure the most recent successful deployment sets the previous to
    # inactive.
    #
    # See: https://docs.github.com/en/rest/reference/repos#inactive-deployments
    #
    # Further, we set required contexts to an empty array because we intend to
    # detect success and failure in our workflow. This avoids an error where
    # workflow status can interfere with creating the deployment.
    #
    # See: https://docs.github.com/en/rest/reference/repos#failed-commit-status-checks
    json='
    {
      "auto_merge": false,
      "environment": "'${environment}'",
      "production_environment": false,
      "ref": "'${sha}'",
      "required_contexts": [],
      "transient_environment": false
    }'
    deployment_id=$(
      printf '%s' $json | curl -s -X POST \
        -H "accept: $ant_man_preview" \
        -H "authorization: token ${token}" \
        "${api_prefix}deployments" \
        --data-binary @- | jq -r '.id'
    )

    printf '%s' $deployment_id
elif [ "$3" == "update" ]; then
    log_url=https://github.com/${owner}/${repo}/commit/${sha}/checks
    ecs_cluster=$([ "$environment" == "staging" ] && echo $staging_cluster || echo $production_cluster)
    environment_url="https://${aws_region}.console.aws.amazon.com/ecs/home?region=${aws_region}#/clusters/${ecs_cluster}/services"
    deployment_id=$4
    state=$5
    json='
    {
      "environment_url": "'${environment_url}'",
      "log_url": "'${log_url}'",
      "state": "'$state'"
    }'
    printf '%s' $json | curl -s -X POST \
        -H "accept: $ant_man_preview" \
        -H "authorization: token ${token}" \
        "${api_prefix}deployments/$deployment_id/statuses" \
        --data-binary @-
else
    printf 'Unrecognized option: %s' $@
    exit 1
fi
