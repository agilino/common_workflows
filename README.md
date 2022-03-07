# Common github actions

Common workflows for CI/CD on github:

* docker workflows:
  * [docker login](./.github/workflows/docker-login.yml) to login to docker registry. Default registry is ghcr.io
  * [docker release](./.github/workflows/docker-docker-release.yml) to run docker build and push.
  * [docker-compos remote](./.github/workflows/docker-compose-remote.yml) to execute docker-compose commands (such as pull and up) on your remote server
* gradle workflows
  * [gradle build](./.github/workflows/gradle-build.yml) run build for unit testing
  * [tagging](.github/workflows/gradle-tag-version.yml) tag repo with version found in build.gradle
  * [gradle publish](./.github/workflows/gradle-publish.yml)
  * [increment version](./.github/workflows/gradle-increment-version.yml) to increment next minor version
* github project workflows if you are using the github project board
  * [move issues to backlog](./.github/workflows/github-issue-move-to-backlog.yml)
  * [move to in progress](./.github/workflows/github-issue-move-to-inprogress.yml) when assigning
  * [move when pull request merged](./.github/workflows/github-issue-move-when-pr-merged.yml)
  * [move when pull request created](./.github/workflows/github-issue-move-when-pr-created.yml)

