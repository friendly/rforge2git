#! /bin/sh

#####################################################################
# script: migrate.sh
# author: M. Friendly <friendly@yorku.ca>
#####################################################################

# Configuration items:

me=`whoami`
svnroot=svn+ssh://${me}@svn.r-forge.r-project.org/svnroot/


package=${1:-candisc}

mkdir ${package}
cd ${package}
git svn clone ${svnroot}${package}/pkg/

# fixup directory

mv pkg/* pkg/.[a-zA-Z]* .


# add remote
git remote add origin git@github.com/${me}:${package}.git

