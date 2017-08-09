#!/usr/bin/env bash

# source this file 

set -v

#####################
### Some shell basics
#####################


## Login process and the dot files

# Two separate files:
# .bash_profile: sourced for login shells
# .bashrc: sourced for non-login shells

# A common pattern:
# .bash_profile -> .bashrc
# .bashrc only run for interactive shells

## Builtins versus commands; looking up help for each

man [[  # no man page? why?
help [[ # Because it is part of the shell.


## Aliases

# Aliases let you define your own command strings, or override existing
# commands.  I use this a lot for typos!
alias

# Set an alias with the syntax "alias name=string".  You can put complicated
# stuff into an alias (just quote/escape it properly) and can pipe to/from
# them as usual.
alias awksum='awk "{sum+=\$1}END{print sum}"'
echo -e '1\n1\n3\n5' | awksum 

# You can use the override feature to give commands default options.  For a lot
# of us that includes a prompt-before-delete option for some commands:
alias cp; alias rm; alias mv

# Or things like color support:
alias ls

# You can override an alias with a backslash, by quoting it, or giving the full
# path if it's a real command.
ls
\ls
/bin/ls


## The env command

# The env command on its own will print out all your current environment
# variables and values.  I've found this very helpful when I'm trying to
# troubleshoot things, for example where a program works for one user but not
# another or one running shell but not another; you can dump env's output to a
# file and diff the two cases to see what variables are different.

env


## The set builtin

# Set with no arguments shows everything that's set for the shell, which
# includes variables but also special things like SHELLOPTS.
set | grep SHELLOPTS

# These options are things you can control with calls to set.
help set

# These are some notable ones in particular:
help set | grep -E -- '-[evC]'


## The which command


## Some notable variables: TERM, PATH, EDITOR, etc.


## Some example shortcuts and control characters

# Pressing CTRL plus any of these will...
# A: go to beginning of line
# E: go to end of line
# L: send "form feed" (new page) control character
# V: allow next character to be entered literally (for example, grep for an
#    actual tab character)


## Using $?

# You can check the exit code of the last command with the special variable
# "$?".  That can be useful when you need to do something more complicated than
# an if or test statement would allow, or when troubleshooting on the fly.

which true
which false
true
echo $?
false
echo $?

########################
### Some specific tricks
########################

# setting default values for variables


DATA_DIR="/data/20170627"
echo ${DATA_DIR:-/data/latest/}
unset DATA_DIR
echo ${DATA_DIR:-/data/latest/}


## Usin the "if main" idiom in scripts

# Like you might already be doing in Python / R / etc., you can make your
# script work as either a standalone program or an ad-hoc library by checking
# how it's called and calling a "main" function if applicable.
# This snippet will call "main" if the containing file is being executed as a
# script, but not if it's being sourced ("included") on the command line or in
# another script.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
    main "$@"
fi
# Thanks to https://stackoverflow.com/a/29967433


## Sourcing a shell script so you can call its functions interactively

# The snippet above makes it easier to import variables and functions from a
# bash script and use them interactively.  I think this is very helpful when
# prototyping things or testing.


## Some useful command-line utilities

# seq: generate sequences (see also {1..10} in newer bash)
# tree: display filesystem tree
# watch: re-run a command repeatedly and monitor the results
# csvtool | less -S: pretty-print tabular data


## compression-enabled commands (zgrep, zcat, less, ...?)


#####################
### Some weird things
#####################

## vim-mode in bash


## Visual quality scores for FASTQ files



FASTQ='@M00281:250:000000000-G1BWR:1:2104:19239:28822 1:N:0:54
TACAATGAACATCCATTTATCCGCCACCCAGATTCAACAGTGGCAAACTTTTTGTCACAGTGGTTTATTTACTTCTAACTAGATCTATCGGTCTATCTATCTATCTATCTATCTATCTATCTATCTATCTATCATCTATCTATCTACATATAAAACTATTTCAATCATTGGCAGATATTATGAC
+
FGDGGGGG5FGGHFFHAGFHHH22EE2FEAA2BGH5AFG2F53223BFGGHFDEAFFFFFA5B5A1AF5GH5FEFGG5DGH3@DGEHF41/EEEH4@@@FBG4EGBGGHFDE4FGHEHHH4?BD?44GDBBGGIIIIIIIIIIDIIIIIIBI3IIIIIIHIIDDIIABIIIIIIII@IBBIIGI
@M00281:250:000000000-G1BWR:1:2104:14675:28924 1:N:0:54
TACAATGAACATCCATTTATCCGCCACCCAGATTCAACAGTGGCAAACTTTTTGTCACAGTGGTTTATTTACTTCTAACTAGATCTATCGGTCTATCTATCTATCTATCTATCTATCTATCTATCTATCTATCTATCATCTATCTATCTACATATAGAACTATTTCAATCATTGGCAGATATTATGAC
+
DGFGGGGGGGGHFHGHHHHHHFGGDFGHGGHHHGHHGHHH5GFGGHGHHHHHGGHEHHHHGDGGFHGGFHHHHH5DGFFFGDHHHHHHHDCFFFHHHFGH4GHHGHHHFHHHHHHHHGHGHHFHGHFFHFDGHHHHHIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
@M00281:250:000000000-G1BWR:1:2104:16891:28948 1:N:0:54
TACAATGAACATCCATTTATCCGCCACCCAGATTCAACAGTGGCAAACTTTTTGTCACAGTGGTTTATTTACTTCTAACTAGATCTATCGGTCTATCTATCTATCTATCTATCTATCTATCTATCTATCTATCATCTATCTATCTACATATAGAACTATTTCAATCATTGGCAGATATTATGAC
+
D33BAGGGGFBFFAEDFG3FGHGGGGFFGCHGHHGHHHHHHHGFFHHHHHHGHGHHHHHHHFHGFFGHHGHEEGHHHHHHHHGHHHGHFGGGGGHGHHHHHGHHHHHHHHGHHHHHHHHGHHHHHHHHHHHHHIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII'



alias fastq_graph="sed -e 'n;n;n;y/!\"#$%&'\''()*+,-.\/0123456789:;<=>?@ABCDEFGHIJKL/▁▁▁▁▁▁▁▁▂▂▂▂▂▃▃▃▃▃▄▄▄▄▄▅▅▅▅▅▆▆▆▆▆▇▇▇▇▇██████/'"


echo "$FASTQ" | fastq_graph


set +v
