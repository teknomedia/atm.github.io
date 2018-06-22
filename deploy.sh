#!/usr/bin/env bash
CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HOME_PATH=$HOME
GHOST_PATH="${HOME_PATH}/.ghost/current"
SERVER_URL="localhost:2373/"

first_deploy() {
    if [ -e "index.html" ]; then
        echo "<!DOCTYPE HTML>" >> index.html
        echo "<html lang=\"en\">" >> index.html
        echo "  <head> >>" index.html
        echo "      <meta charset=\"UTF-8\">" >> index.html
        echo "      <meta http-equiv=\"refresh\" content=\"1; url=static/index.html\">" >> index.html
        echo "      <script>window.location.href = \"static/index.html\"; </script> >>" index.html
        echo "       <title>Page Redirection</title>" >> index.html
        echo "  </head> >>" index.html
        echo "<body> >>" index.html
        echo "  If you are not redirected automatically, follow the <a href='static/index.html'>link to home page</a>. " >> index.html
        echo "</body>" >> index.html
        echo "</html>" >> index.html
    fi
    # Expects an input from user to provide a Git remote URL in which Ghost will be deployed.
    echo ' -------------------- INFORMATION NEEDED -------------------- '
    echo ''
    echo "Following you'll be asked to enter a Git Remote URL in which you would like to deploy Ghost."
    echo "Example:"
    echo "       git@github.com:YOUR_USERNAME/YOUR_REPOSITORY.git"
    echo ''
    read -p "Remote URL: "  remote_url

    # Setting up buster on the current folder.
    buster setup --gh-repo="$remote_url"
    buster generate --domain="$SERVER_URL"

    git init
    git remote add origin "$remote_url"

    # Add .gitignore
    if [ -f "gitignore.base" ]; then
        $(rm -f .gitignore)
        $(cp gitignore.base .gitignore)
    fi

    git add -A
    git commit -m "First commit on Github Pages using Ghost."
    git push origin master:master master:gh-pages -f
}

update() {
    # Generating static files
    buster generate --domain="$SERVER_URL"

    # Commiting changes to repository in order to deploy new content.
    git add -A
    git commit -m "Update on the website at $(date)"
    git push origin master:master master:gh-pages -f
}
		
deploy() {
	# Check if repo already exists on current path
    repo_exists="$(git status)"
    case "fatal" in 
        *"$repo_exists"*)
            echo '[INFO] Configuring git repository...'
            echo '[INFO] Generating static files from Ghost server...'
            first_deploy
            exit
        ;;
    esac
    echo '[INFO] Deploying to your Github repository...'
    update
}
deploy


