#!/bin/sh

################################################################################
# Title         : .deploy-doc.sh
# Date created  : 2 August 2018
__AUTHOR__="Erriez"
#
# This script will generate Doxygen documentation and push the documentation to
# the gh-pages branch of a repository specified by GH_REPO_REF.
#
# Preconditions:
# - A gh-pages branch should already exist in the GitHub project.
# - Doxygen binaries must be in the path.
# - Doxygen configuration file:
#   - Path must include $(TRAVIS_BUILD_DIR) prefix, for example:
#     - PROJECT_LOGO = $(TRAVIS_BUILD_DIR)/extras/Project.png
#     - INPUT = $(TRAVIS_BUILD_DIR)/src \
#               $(TRAVIS_BUILD_DIR)/README.md
#   - OUTPUT_DIRECTORY =
#   - HTML_OUTPUT = .
# - Set global variables in .travis.yml:
#   - DOXYFILE            : The Doxygen configuration file, for example: $TRAVIS_BUILD_DIR/Doxyfile
#   - GH_REPO_NAME        : The name of the GitHub repository.
#   - GH_REPO_REF         : github.com/<USER>/<REPOSITORY_NAME>.git
# - Set global variable in Travis project settings, explained in next chapters:
#   - GH_REPO_TOKEN       : Secure token to the github repository.
#
# Create a Secure token to the github repository:
# - Create GitHub personal access token to allow Travis pushing the generated Doxygen files to the
#   gh-page branch:
#   1. In GitHub, go to Settings (under user menu) | Developer settings | Personal access tokens:
#   2. Click "Generate new token" and fill in the description. E.g. "Doxygen push Travis CI"
#   3. Check under Select scopes "public_repo"
#   4. Click "Generate token"
#   5. Copy the generated token and put it on a safe place. It is displayed once and cannot be
#      retrieved.
#
# - Add the secure variable to Travis CI:
#   1. Go to the repository in Travis CI and click "More options | Settings".
#   2. Create a new environment variable in the "Environment Variables" section:
#      - Name: GH_REPO_TOKEN
#      - Value: Paste the copied token.
#      - UNCHECK: Display value in build log (MUST BE OFF!)
#   3. Click on Add;
#
################################################################################

################################################################################
##### Setup this script and get the current gh-pages branch.               #####
echo 'Setting up the script...'

# Exit with nonzero exit code if anything fails
set -e

# Create a clean working directory for this script.
mkdir code_docs
cd code_docs

# Get the current gh-pages branch
git clone -b gh-pages https://git@$GH_REPO_REF
cd $GH_REPO_NAME

##### Configure git.                                                       #####
# Set the push default to simple i.e. push only the current branch.
git config --global push.default simple
# Pretend to be an user called Travis CI.
git config user.name "Travis CI"
git config user.email "travis@travis-ci.org"

# Remove everything currently in the gh-pages branch.
# GitHub is smart enough to know which files have changed and which files have
# stayed the same and will only update the changed files. So the gh-pages branch
# can be safely cleaned, and it is sure that everything pushed later is the new
# documentation.
rm -rf *

# Need to create a .nojekyll file to allow filenames starting with an underscore
# to be seen on the gh-pages site. Therefore creating an empty .nojekyll file.
# Presumably this is only needed when the SHORT_NAMES option in Doxygen is set
# to NO, which it is by default. So creating the file just in case.
echo "" > .nojekyll

################################################################################
##### Generate the Doxygen code documentation and log the output.          #####
echo 'Generating Doxygen code documentation...'
# Redirect both stderr and stdout to the log file AND the console.
doxygen $DOXYFILE 2>&1 | tee doxygen.log

################################################################################
##### Generate Doxygen PDF                                                 #####
if [ -d "latex" ] && [ -f "latex/Makefile" ]; then
    echo 'Generating PDF'
    cd latex
    make
    # Cleanup
    rm -f *.ps *.dvi *.aux *.toc *.idx *.ind *.ilg *.out *.brf *.blg *.bbl
    # Rename output PDF file
    mv refman.pdf ${GH_REPO_NAME}.pdf
    cd ..
else
    echo '' >&2
    echo 'Warning: No latex/Makefile have been found!' >&2
    echo 'Warning: Not going to push the documentation to GitHub!' >&2
    exit 1
fi

################################################################################
##### Upload the documentation to the gh-pages branch of the repository.   #####
# Only upload if Doxygen successfully created the documentation.
# Check this by verifying that the file index.html exist. This is a good
# indication that Doxygen did it's work.
if [ -f "index.html" ]; then

    echo 'Uploading documentation to the gh-pages branch...'
    # Add everything in this directory (the Doxygen code documentation) to the
    # gh-pages branch.
    # GitHub is smart enough to know which files have changed and which files have
    # stayed the same and will only update the changed files.
    git add --all

    echo 'git commit  with build: ${TRAVIS_BUILD_NUMBER} commit: ${TRAVIS_COMMIT}'
    # Commit the added files with a title and description containing the Travis CI
    # build number and the GitHub commit reference that issued this build.
    git commit -m "Deploy code docs to GitHub Pages Travis build: ${TRAVIS_BUILD_NUMBER}" -m "Commit: ${TRAVIS_COMMIT}"

    # Force push to the remote gh-pages branch.
    # The ouput is redirected to /dev/null to hide any sensitive credential data
    # that might otherwise be exposed.
    echo 'git push --force'
    git push --force "https://${GH_REPO_TOKEN}@${GH_REPO_REF}" > /dev/null 2>&1
else
    echo '' >&2
    echo 'Warning: No documentation (html) files have been found!' >&2
    echo 'Warning: Not going to push the documentation to GitHub!' >&2
    exit 2
fi
