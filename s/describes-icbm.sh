#!/bin/sh -e

# No user-serviceable parts          
if [ -z "$PORTSNAP_BUILD_CONF_READ" ]; then
	echo "Do not run $0 manually"
	exit 1
fi

# usage: sh -e describes-icbm.sh GOODHASH BADHASH ERRFILE
GOODHASH="$1"
BADHASH="$2"
ERRFILE="$3"

# Standard From/To/Subject lines
cat <<EOF
From: ${INDEXMAIL_FROM}
To: ${INDEXMAIL_TO}
Subject: INDEX build breakage
EOF

# CC people who might have broken the INDEX
git --git-dir=${STATEDIR}/repodir log --format=%aE ${GOODHASH}..${BADHASH} |
    sed 's/^/CC: /'

# Blank line and build failure output
echo
cat ${ERRFILE}

# List potentially at-fault committers (again) and SVN history
echo
echo "Committers on the hook (CCed):"
echo $(git --git-dir=${STATEDIR}/repodir log --format=%aE ${GOODHASH}..${BADHASH})

echo "Latest commits:"
git --git-dir=${STATEDIR}/repodir log --oneline ${GOODHASH}..${BADHASH}

# Final message about when emails are sent
cat <<EOF

There may be different errors exposed by INDEX builds on other
branches, but no further emails will be sent until after the
INDEX next builds successfully on all branches.
EOF
