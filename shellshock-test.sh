#!/bin/bash
# This script tests Bash and ZSH for shellshock vulnerability

# Further testing:
# http://shellshock.brandonpotter.com/
# http://www.shellshocktest.com/
# http://bashsmash.ccsir.org/


env x='() { :;}; echo vulnerable!!!' zsh -c 'echo ZSH Test'
env x='() { :;}; echo vulnerable!!!' bash -c 'echo Bash Test 1'
env 'VAR=() { :;}; echo vulnerable!!!' 'FUNCTION()=() { :;}; echo Bash is vulnerable!' bash -c "echo Bash Test 2"
