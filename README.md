# Common github actions

Common workflows for CI/CD on github:


* [unit testing](./.github/workflows/unit-test.yml) on push to any branch
* [tagging](.github/workflows/tag-version.yml) on push to master 
* [gradle publish](./.github/workflows/backend-release.yml) to release Java Backend after tagging the version
* [docker push](./.github/workflows/docker-release.yml) to tag and push your docker image to github container registry (ghcr.io)
* project workflows if you are using the github project board
  * [move issues to backlog](./.github/workflows/move-issue-to-backlog.yml)
  * [move to in progress](./.github/workflows/move-move-issue-to-inprogress.yml) when assigning
  * [move when pull request merged](./.github/workflows/move-issue-when-pr-merged.yml)
  * [move when pull request created](./.github/workflows/move-issue-when-pr-created.yml)
