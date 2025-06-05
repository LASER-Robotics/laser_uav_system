#!/bin/bash

# remove the old link
 rm .tmuxinator.yml


# link the session file to .tmuxinator.yml
ln session.yml .tmuxinator.yml

# start tmuxinator
tmuxinator
