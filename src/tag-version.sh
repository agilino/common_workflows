#!/usr/bin/env bash

# tag-version.sh
# Insipred by Julian Sangillo adapted to single branch flow
# Use: tag-version {prod-branch}
# Output: {new-revision}
# Provides automated versioning of your commits using git tags each time your CI/CD workflow runs.
# Error Codes:
# - 32: A 'latest' tag exists without a corresponding annotated tag marking the last known version on the same commit.
# - 128: Tag version is being attempted on neither the production, test, or dev branches. Branch is unknown.

PROD_BRANCH="$1";
GITHUB_ACTOR="$2"
PREFIX="$3"

outLog() {
    echo "$1"
} >&2

getLatestRevision() {
    outLog "Getting latest tagged revision ...";
    latest=$(git describe --tags --abbrev=0 --always --first-parent)
    if [ -z "$latest" ]; then
        echo "NA";
        return 0
    fi
    if [ -n "$PREFIX" ]; then
        # return semVer without prefix
        echo ${latest#$PREFIX}
        return 0
    fi
    echo ${latest}
}

isBreakingChange() {
  local MESSAGE="$(getLatestMessage)";
  local REGEX=".*(feat|fix|perf|refactor|style|test|build|ops|docs|chore|merge)(\(.*\)!:|!:).*";
  if [[ "$MESSAGE" == *"BREAKING CHANGE"* || $MESSAGE =~ $REGEX ]]; then
    echo 0
  else
    echo 1
  fi
}

getLatestMessage() {
  local MESSAGE="$(git show -s HEAD)";
  # replace line break for easier regex search
  MESSAGE="${MESSAGE//[[:cntrl:]]/}"
  echo $MESSAGE;
}

getRevisionType() {
    local BRANCH="$1";
    local MESSAGE="$(getLatestMessage)";

    outLog "Getting revision type from commit message ...";
    outLog "(major, minor, build)";
    outLog "Message: $MESSAGE";

    local INCREASE_MAJOR="$(isBreakingChange)"
    if [[ ${INCREASE_MAJOR} == 0 ]]; then
        echo "major"
    elif [[ $MESSAGE =~ .*(feat)(\(.*\):|:).* ]]; then
        echo "minor"
    else
        echo "build"
    fi
}

split() { IFS="$1" read -r -a return_arr <<< "$2"; }

join() { local IFS="$1"; shift; echo "$*"; }

getNewRevision() {
    local REVISION_TYPE="$1";
    local OLD_VERSION="$2";

    outLog "Getting new revision from revision type and the old version ...";
    outLog "Revision Type: $REVISION_TYPE";

    if [ "$OLD_VERSION" = "NA" ]; then
        outLog "Old version doesn't exist. Using initial version.";
        echo "0.1.0";
        return 0
    fi

    outLog "Old Version: $OLD_VERSION";

    split '.' $OLD_VERSION;

    major_revision=${return_arr[0]};
    minor_revision=${return_arr[1]};
    build_number=${return_arr[2]};

    case $REVISION_TYPE in
        major)
            ((major_revision++));
            minor_revision=0;
            build_number=0
            ;;
        minor)
            ((minor_revision++));
            build_number=0
            ;;
        build)
            ((build_number++))
            ;;
        esac

    echo "$(join . $major_revision $minor_revision $build_number)"
}

tagRelease() {
    local REVISION_TYPE="$1";
    local REVISION="$2";

    local MESSAGE="${REVISION_TYPE} $REVISION";

    outLog "Tagging new release ...";
    outLog "Revision Type: $REVISION_TYPE";
    outLog "Revision: $REVISION";
    outLog "Annotated Message: $MESSAGE";
    outLog "tagging as ${GITHUB_ACTOR}"
    git config --global user.email "${GITHUB_ACTOR}@users.noreply.github.com"
    git config --global user.name "${GITHUB_ACTOR}"
    git tag -a "${PREFIX}$REVISION" -m "$MESSAGE";
}

pushToOrigin() {
    outLog "Pushing changes to origin ...";
    git push --tags 2> /dev/null;

    outLog "Push successful.";
}

outLog "Production Branch: $PROD_BRANCH";
outLog "Test Branch: $TEST_BRANCH";
outLog "Dev Branch: $DEV_BRANCH";

BRANCH="$(git branch --show-current)";
outLog "Current branch: $BRANCH";

REVISION="$(getLatestRevision)";
outLog "Latest Revision: $REVISION";

if [ -z "$REVISION" ]; then
    outLog "Tag version failed! Version must exist at :latest";
    exit 32;
fi

if [ "$REVISION" != "NA" ]; then
    REVISION_TYPE="$(getRevisionType)";
else
    REVISION_TYPE="minor";
fi
outLog "Revision Type: $REVISION_TYPE";

if [ "$BRANCH" = "$PROD_BRANCH" ]; then
    outLog "Releasing for production.";
    NEW_REVISION="$(getNewRevision $REVISION_TYPE $REVISION)";
    IS_PRERELEASE='false';
else
    outLog "Tag version failed! Unknown branch '$BRANCH'";
    exit 128;
fi
outLog "New Revision: $NEW_REVISION";

tagRelease $REVISION_TYPE $NEW_REVISION;
pushToOrigin;

outLog "Tag version complete.";
outLog "Output: $NEW_REVISION";
echo "::set-output name=revision::$NEW_REVISION";
echo "::set-output name=is-prerelease::$IS_PRERELEASE"
