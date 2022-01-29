# Pathstream ECS Deploy

This encodes the default ECS service deploy to Pathstream internal clusters. It
was extracted from the pathstream/learning repo for reuse across all
applications

**Warning: Public access**

This is public because shared workflows are required to be public. Make sure to
pass in important details via secrets or parameters rather than encode details
directly into the workflow.



## Using this task

Assumptions built into the main deploy workflow:

1. Migrations run before deploying
2. A worker service (name `$SERVICE-worker-$ENV`, container name `$SERVICE-worker`)
3. An http service (named `$SERVICE-api-$ENV`, container name `$SERVICE-api`)
4. us-west-2
5. datadog-agent container defined
6. log_router container defined

Requirements to make it all go:

bin/gh-deployment.sh should exist in the repo to set up the deployment




