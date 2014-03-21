git-remote-deploy
=================

Git Remote Deploy is a post-update hook for git which helps in deploying your source code 
to a remote server path by simply pushing your commits to the remote server.

This deployment script was inspired by this article: http://goo.gl/s4Eksv

In order to setup the deployment of your source code, follow the steps shown below:

# Setup repository on deployment server
This usualy is your webserver where you want to deploy your code

    ssh <remote server>
    mkdir ~/src
    cd ~/src
    git init --bare project.git
    
# Configure repository mapping
This is required so that you can map your repository branches to be deployed onto a certain
path on the file system. e.g. master branch deploy to /var/www/project-production

    git config deploy.development "/var/www/project-staging"
    git config deploy.master "/var/www/project-production"

The .master and .development part of the above config refers to the branches available in 
your repository. Change them according to your needs.
    
# Install the post-commit hook
We now download the post-commit hook and put it in the hooks folder of the repository

    wget https://github.com/jeffery/git-remote-deploy/raw/master/git-remote-deploy.sh
    mv git-remote-deploy.sh ~/src/project.git/hooks/post-update
    chmod +x ~/src/project.git/hooks/post-update
    
# Setup git config in working copy
Finally we setup our local working copy with appropriate config to push your code to
the remote server.

    git remote add production ssh://<remote server>/home/<username>/src/project.git
    git push production +development:refs/heads/development
    
The above configuration adds a new remote repository called "production", ready to deploy
your development branch to /var/www/project-staging on your remote server.

We can test if this works by making a test commit and pushing the code to the remote server
While in your working copy "development" branch, execute the following commands:

    touch test
    git add test
    git commit -m "Adding test file"
    git push production development
    
The above push should deploy your repository code onto the remote server.
    
