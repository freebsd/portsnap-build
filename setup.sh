#!/bin/sh -e
set -e

# usage: sh -e setup.sh

# Load configuration
. build.conf

# Make the state directory
mkdir ${STATEDIR}
chmod 700 ${STATEDIR}

# Describes state
mkdir ${STATEDIR}/describes

# Instruct the user about unbuilt DESCRIBE files
UNBUILT=""
for N in ${DESCRIBES_PUBLISH}; do
	NEED=1
	for M in ${DESCRIBES_BUILD}; do
		if [ $N = $M ]; then
			NEED=0
		fi
	done
	if [ $NEED = 1 ]; then
		UNBUILT="${UNBUILT} DESCRIBE.${N}"
	fi
done
xargs -s 80 <<- EOF
	The files ${UNBUILT} are set to be published but are not in the
	list to be built; please create them in the directory
	${STATEDIR}/describes.  (These are probably DESCRIBE files for
	old STABLE branches which no longer supported.)
EOF
echo

# Fileset state
mkdir ${STATEDIR}/fileset ${STATEDIR}/fileset/oldfiles
touch ${STATEDIR}/fileset/filedb
touch ${STATEDIR}/fileset/metadb
touch ${STATEDIR}/fileset/extradb

# Instruct the user about the need for a world tarball
xargs -s 80 <<- EOF
	If you haven\\'t already done so, please create a .tar file in
	${WORLDTAR} containing the portion of the FreeBSD world needed
	for \\'make describe\\' to run.
EOF

# Create a directory for keys
mkdir ${STATEDIR}/keys

# Instruct the user about creating keys
echo
xargs -s 80 <<- EOF
	Before you can perform Portsnap builds, you need to run keygen.sh
	to create a signing key.
EOF
echo
# Create a staging area for files waiting to be uploaded
mkdir ${STATEDIR}/stage
mkdir ${STATEDIR}/stage/f
mkdir ${STATEDIR}/stage/bp
mkdir ${STATEDIR}/stage/t
mkdir ${STATEDIR}/stage/s

# Clone initial repo in ${STATEDIR}/gitrepo
# In the svn era portsnap performed metadata operations (i.e., finding the
# latest revision number) against the svn server.  With git we need a local
# copy of the repository for all operations.  Perform an initial clone here,
# which we will update (git fetch) in build.sh and then create worktrees from
# it as needed.
git clone --bare ${REPO} ${STATEDIR}/gitrepo
