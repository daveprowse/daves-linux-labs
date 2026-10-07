#!/bin/bash
# Copyright (c) 2026 Dave Prowse | MIT License
# Companion script for Prowse Tech (Dave's Linux Labs)

# tmux-workspace.sh
# Launches a pre-configured Tmux workspace
# Windows: SSH (left-right), sysadmin (three-way), code (up-down)
# Don't forget to set permissions: chmod +x tmux-workspace.sh 
# Adjust how you see fit!

SESSION="tmux-workspace"

# Attach if session already exists
tmux has-session -t $SESSION 2>/dev/null && tmux attach -t $SESSION && exit

# Window 1 — SSH (left-right split, path: ~/.ssh)
tmux new-session -d -s $SESSION -n "SSH" -c ~/.ssh
tmux split-window -h -t $SESSION:SSH -c ~/.ssh

# Window 2 — sysadmin (three-way: left | right-top / right-bottom)
tmux new-window -t $SESSION -n "sysadmin"
tmux split-window -h -t $SESSION:sysadmin
tmux split-window -v -t $SESSION:sysadmin.1

# Window 3 — code (up-down split)
tmux new-window -t $SESSION -n "code"
tmux split-window -v -t $SESSION:code

# Start on Window 1, left pane
tmux select-window -t $SESSION:SSH
tmux select-pane -t $SESSION:SSH.0

# Attach
tmux attach -t $SESSION