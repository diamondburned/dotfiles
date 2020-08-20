#!/bin/sh
# gets executed
prompt='$(./lineprompt "$ $HOSTNAME @ $PWD")'

arrow="\[\033[9m\]\[\033[38;5;135m\] ❤ \[\033[0m\]\[\033[38;5;135m\]▻\[\033[m\] "

printf -v PROMPT_COMMAND "PS1=%q$'\n'%q" "$prompt" "$arrow"

