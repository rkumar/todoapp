#!/bin/bash
#*******************************************************#
#                      todoapp.sh                       #
#                 written by Rahul Kumar                #
#                    2009/12/14                         #
#           Yet another small, cute todo app            #
#           Licensed under GPL                          #
#           http://www.gnu.org/copyleft/gpl.html        #
#                                                       #
#           v1.0.0 Initial Release                      #
#           v2.0.0 subtask in separate line             #
#*******************************************************#
# TODO: all functions should now be the same, avoid subtask subcommand
# Minimal installation, creates a file in the current
#+ folder, so you can have todo files in multiple projects

# the only configuration the user need do. The name of the output file
TODO_FILE="TODO2.txt"
COLORIZE=1   # if you want colored output, else comment out
# COLORIZE requires external file colors.sh in PATH
# get_serial_number required in path

FULLAPPNAME="$0"
APPNAME=$( basename $0 )
VERSION="2.0.0"
DATE="2009-12-16"
AUTHOR="rkumar"
today=$( date '+%Y-%m-%d' )
DELIM=$'\t'
TAB="	"
shopt -s extglob

USAGE="$APPNAME [--project PROJECT] [--component COMP] [--priority A-Z] action #ITEM"
# ---------------------------------------------------------------------------- #
# usage
# description of usage
# ---------------------------------------------------------------------------- #
usage ()
{
    sed -e 's/^    //' <<EndUsage
    Usage: $USAGE
    Try '$APPNAME -h' for more information.
EndUsage
    exit 1
}
# ---------------------------------------------------------------------------- #
# help
# display help
# ---------------------------------------------------------------------------- #
help ()
{
    sed -e 's/^    //' <<EndHelp
      Usage: $USAGE

      Actions:
      add
         [suboptions] add "todo item"
         add suboptions:
         -P | --project  add project name to item
         -C | --component add component or context name to item
         -p | --priority  add priority to item

      delete
         delete #ITEM

      mark | status #ITEM <state> 
         state - one of start,close, unstarted, pend, hold, next

      list
         listing of tasks
         list sub-options:
         --no-colors  don't show colors
         --colors     show colors

      subtask [add | delete | mark] ITEM# [args]
         add ITEM# text
         add a subtask to the given item with given text

         del ITEM#.SUBTASK#
         delete the subtask (e.g. subtask del 3.4)

         mark ITEM#.SUBTASK# <state>
         mark the state of the given task (e.g. subtask mark close 3.5)

EndHelp
}



# ---------------------------------------------------------------------------- #
# validate_item
# validates item number from todo file
# @param   : item
# ---------------------------------------------------------------------------- #
validate_item ()
{
   item="$1"  # item
   if [[ -z "$item" ]]; then
      die "Item required. $errmsg"
   fi
   [[ "$item" = +([0-9]) ]] || die "Item should be numeric. $errmsg"
   check_file
   paditem=$( printf "%3s" $item )
   todo=$( grep "^$paditem" "$TODO_FILE" )
   if [[ -z "$todo" ]]; then
      die "Item $item not found in $TODO_FILE. $errmsg"
   fi
}

# ---------------------------------------------------------------------------- #
# die
# prints error message and exits
# @param   : message
# ---------------------------------------------------------------------------- #
die ()
{
   message="$1"  # rem _
   echo "$message" 1>&2
   exit 1
}

cleanup ()
{
   # rm .bak file
   exit 0
}

# ---------------------------------------------------------------------------- #
# add
# add an item
# @param   : text
# ---------------------------------------------------------------------------- #
add ()
{
   text="$*"  # rem _
   if [[ -z "$text" ]]; then
      echo -n "Enter todo:"
      read text
      if [[ -z "$text" ]]; then
         echo "Got nothing. Exiting."
         exit 1
      fi
   fi
   appname=$( basename $( pwd ) )
   item=$( get_serial_number -a "$appname" -d "$(pwd)" )
   paditem=$( printf "%3s" $item )
   [ -z "$item" ] && { echo "No item number to add"; exit 1; }
   [ ! -z "$project" ] && project=" +${project}"
   [ ! -z "$component" ] && component=" @${component}"
   [ ! -z "$priority" ] && priority=" (${priority})"
   newtext="${paditem}${DELIM}[ ]${priority}${project}${component} $text ($today)"
   echo "$newtext" >> "$TODO_FILE"
   echo "Added $item to $TODO_FILE"
}
# ---------------------------------------------------------------------------- #
# list
# list todos
# @param   : param1
# @param   : param2
# @return  : returns 
# ---------------------------------------------------------------------------- #
# # TODO --hide-sub or --level/depth
list ()
{
   #items=$( sort -t$'\t' -k2 "$TODO_FILE" )
   items=$( sed -e :a -e '$!N;s/\n\( *\)-/~\1-/;ta' -e 'P;D' "$TODO_FILE" | sort -t'	' -k2  | tr '~' '\n' )
   #total=$( echo "$items" | wc -l ) 
   filter=""
   [[ ! -z "$project" ]] && { items=$( echo "$items" | grep +${project} ) ; }
   [[ ! -z "$component" ]] && { items=$( echo "$items" | grep @${component} ) ; }

   if [[ "$COLORIZE" = "1"  ]]; then
      DEL="	"
      COL_BG_NORM=$(tput setab 9)
      COL_FG_NORM=$(tput setaf 9)
      COL_BG_RED=$( tput setab 1 )
      COL_FG_RED=$( tput setaf 1 )
      COL_BG_GREEN=$( tput setab 2 )
      . colors.sh ## XXX put path outside
      #items=$( echo "$items" | sed "s/\(\[[ 1]\]\)/${COL_BG_RED}\1${COL_BG_NORM}/" )
      items=$( echo "$items" \
      | sed "s/\[?\]/${COL_BG_RED}[ ]${COL_BG_NORM}/; \
      s/${DEL}\[x\]/${DEL}${COL_FG_RED}[x]${COL_FG_NORM}/g; \
      /\[ \] (A)/s/.*/${COLOR_YELLOW}&${COLOR_DEFAULT}/; \
      /\[ \] (B)/s/.*/${COLOR_WHITE}&${COLOR_DEFAULT}/; \
      /\[ \] (C)/s/.*/${COLOR_CYAN}&${COLOR_DEFAULT}/; \
      /\[ \] (D)/s/.*/${COLOR_GREEN}&${COLOR_DEFAULT}/; \
      /\[ \] ([E-Z])/s/.*/${COLOR_BROWN}&${COLOR_DEFAULT}/; \
      s/\[X\]/${COL_BG_RED}[1]${COL_BG_NORM}/" 
      )
   fi
   # taking care of subtasks
   echo -e "$items" | tr -s '' | sed 's//        /g;s/	/ /g' | tr '' '\n'
   shown=$( echo "$items" | wc -l ) 
   echo 
   echo "Shown $shown of $total items from $TODO_FILE"
}
# ---------------------------------------------------------------------------- #
# delete
# delete an item based on number displayed on left
# @param   : item
# @return  : returns 
# ---------------------------------------------------------------------------- #
delete ()
{
   item="$1"  # rem _
   errmsg="usage: $APPNAME delete #item"
   validate_item "$item" "$errmsg"
   echo -n "Do you wish to delete: $todo" '[y/n] ' ; read ans
   case "$ans" in
      y*|Y*) 
      sed -i.bak "/^$paditem/d" "$TODO_FILE"
      if [  $? -eq 0 ]; then
         echo "Delete $item successful"
      fi
      ;;
      *) echo "No item deleted"  ;;
   esac
   delchildren $item
   
}
# ---------------------------------------------------------------------------- #
# priority
# Add a priority to a todo. Helps in sorting and coloring.
# @param   : priority A-Z
# @param   : item
# ---------------------------------------------------------------------------- #
priority ()
{
   item="$2"  # 
   newpri="$1"
   TAB="	" # tab
   errmsg="usage: $APPNAME priority [A-Z] #item"
   newpri=$( printf "%s\n" "$newpri" | tr 'a-z' 'A-Z' )
   [[ "$newpri" = @([A-Z]) ]] || die "$errmsg"
   validate_item "$item" "$errmsg"
   # if a priority exists, remove it. Remove only main task pri
   if grep -q "${TAB}\[.\] ([A-Z])" <<< "$todo"; then
      todo=$( echo "$todo" | sed 's/] ([A-Z]) /] /' )
   fi
   # add new priority exists
   todo=$( echo "$todo" | sed "s/] /] ($newpri) /" )
   sed -i.bak "/$paditem/s/.*/$todo/" "$TODO_FILE"
   if [  $? -eq 0 ]; then
      echo "Change priority for $item successful"
   fi
   cleanup
}
# ---------------------------------------------------------------------------- #
# depri
# Remove priority from item
# @param   : item
# ---------------------------------------------------------------------------- #
depri ()
{
   item="$1"  # 
   errmsg="usage: $APPNAME depri #item"
   validate_item "$item" "$errmsg"
   # if a priority exists, remove it
   #if grep -q "\[.\] ([A-Z])" <<< "$todo"; then
   TAB="	" # tab
   if grep -q "${TAB}\[.\] ([A-Z])" <<< "$todo"; then
      todo=$( echo "$todo" | sed 's/] ([A-Z]) /] /' )
      sed -i.bak "/$paditem/s/.*/$todo/" "$TODO_FILE"
      if [  $? -eq 0 ]; then
         echo "Removed priority for $item."
      fi
      cleanup
   else
      echo "No priority found on: $todo."
   fi
}
# ---------------------------------------------------------------------------- #
# mark
# mark an item as complete, started, open etc
# @param   : item
# @param   : status
# ---------------------------------------------------------------------------- #
status ()
{
   item="$1"  # rem _
   status="$2"  # rem _

    errmsg="usage: $APPNAME ITEM# status [start|pend|close|hold|next|unstarted] "
    newstatus=$( echo $status | sed 's/^start/@/;s/^pend/P/;s/^close/x/;s/hold/H/;s/next/1/;s/^unstarted/ /' )
    if [[ ${#newstatus} != 1 ]]; then
       echo "Error! Given status invalid ($newstatus)"
       die "$errmsg"
    fi
    validate_item "$item" "$errmsg"
    sed -i.bak "/$paditem/s/\(.*\)\[.\]\(.*\)$/\1[$newstatus]\2/" "$TODO_FILE"
    if [  $? -eq 0 ]; then
       echo "Item $item marked as $status"
    else
       echo "Operation failed. "
    fi
    markchildren "$item" $newstatus
    cleanup
}
validate_subtask ()
{
   item="$1"  # item
   shift
   errmsg="$*"
   if [[ -z "$item" ]]; then
      die "Item required. $errmsg"
   fi
   #[[ "$item" = +([0-9]) ]] || die "Item should be numeric. $errmsg"
   check_file
   #paditem=$( printf "%3s" $item )
   todo=$( grep -n "^ *- $item${TAB}" "$TODO_FILE" )
   if [[ -z "$todo" ]]; then
      die "Subtask $item not found in $TODO_FILE. $errmsg"
   fi
   lineno=$( echo "$todo" | cut -d: -f1 )
   todo=$( echo "$todo" | cut -d: -f2 )
   #item=$( expr $fullitem : '\([0-9]\+\)\.')
   #validate_item "$item" "$errmsg"
}
marksub ()
{
   fullitem="$1"  
   status="$2"  
   TAB="	"

    errmsg="usage: $APPNAME ITEM# status [start|pend|close|hold|next|unstarted] "
    newstatus=$( echo $status | sed 's/^start/@/;s/^pend/P/;s/^close/x/;s/hold/H/;s/next/1/;s/^unstarted/ /' )
    if [[ ${#newstatus} != 1 ]]; then
       echo "Error! Given status invalid ($newstatus)"
       die "$errmsg"
    fi
    #   validate_item "$item" "$errmsg"
    validate_subtask "$fullitem" "$errmsg"
    #sed -i.bak "/$paditem/s/\(.*\)\[.\]\(.*\)$/\1[$newstatus]\2/" "$TODO_FILE"
    sed -i.bak "/^ *- $fullitem/s/${fullitem}${TAB}\[.\]/${fullitem}${TAB}[$newstatus]/" "$TODO_FILE"
    if [  $? -eq 0 ]; then
       echo "Item $fullitem marked as $status"
    else
       echo "Operation failed. "
    fi
    markchildren "$fullitem" $newstatus
    cleanup

}

markchildren ()
{
   local item="$1"
   local status="$2"
   if grep -q "^ *- ${item}\.[0-9\.]*${TAB}" "$TODO_FILE"; then
      :
   else
      return 0
   fi
   echo -n "Do you wish to mark subtasks of $item" '[y/n] ' ; read ans
   case "$ans" in
      y*|Y*) : ;;
      *) return 0;;
   esac
   
   sed -i.bak "/^ *- ${item}\.[0-9\.]*${TAB}/s/${TAB}\[.\]/${TAB}[$newstatus]/" "$TODO_FILE"
    if [  $? -eq 0 ]; then
       echo "Subtasks of Item $item marked as $status"
    else
       echo "Operation failed. "
    fi
}
delchildren ()
{
   local item="$1"
   sed -i.bak "/^ *- ${item}\.[0-9\.]*${TAB}/d" "$TODO_FILE"
    if [  $? -eq 0 ]; then
       echo "Subtasks of Item $item deleted"
    else
       echo "Operation failed. "
    fi
}

addsub ()
{
   fullitem=$1
   TAB="	" # tab
   DELIM="${TAB}"
   shift
   subtask="$*"
   #validate_item "$item" "$errmsg"
   #validate_subtask "$fullitem" "$errmsg"
   full=$( grep -n -e "- ${fullitem}\.[0-9]*${TAB}" "$TODO_FILE" | tail -1 )
   last=$(echo "$full" | cut -d'-' -f2 | grep -o '^ [0-9\.]\+' | tr -d '[:space:]' ) 
   echo "full:$full"
   echo "last:$last"
   if [[ -z "$full" ]]; then
      full=$( grep -n -e " ${fullitem}${TAB}" $TODO_FILE )
      prev=$(echo "$full" | cut -d'-' -f2 | grep -o '^ [0-9\.]\+' | tr -d '[:space:]' ) 
      echo "prev: $prev"
      [[ -z "$prev" ]] && { echo "error $fullitem"; exit 1; }
      last="$prev"
      line=$( expr "$full" : '^\([0-9]\+\):' )
      indent=$( expr "$full" : '^[0-9]\+:\( \+\)')
      indent+="   "
      echo "x${indent}y"
      # get higher level
   else
      lastchild=$( grep -n -e "- ${fullitem}\.[0-9]*\.[0-9]*" "$TODO_FILE" | tail -1 )
      if [[ -z "$lastchild" ]]; then
         line=$( expr "$full" : '^\([0-9]\+\):' )
      else
         line=$( expr "$lastchild" : '^\([0-9]\+\):' )
      fi
      indent=$( expr "$full" : '^[0-9]\+:\( \+\)')
      #indent=$( expr "$last" : '\([^-0-9]\+\)' )
      echo "X${indent}Y"
   fi
      echo ""
      echo "last:$last"
      highest=$( echo "$last" | cut -d' ' -f2 )
      echo "line: $line, highest: $highest"
      base=$(expr $highest : '.*\.\([0-9]\+\)$')
      len=$(( ${#highest}-${#base}-0 ))
      echo "len: $len"
      part1="${highest:0:${len}}"
      (( base++ ))
      echo "next: $base, ${part1}${base}"
      newnum="${part1}${base}"
   [ ! -z "$project" ] && project=" +${project}"
   [ ! -z "$component" ] && component=" @${component}"
   [ ! -z "$priority" ] && priority=" (${priority})"
   #newtext="${paditem}${DELIM}[ ]${priority}${project}${component} $text ($today)"
   newtodo="${indent}- ${newnum}${DELIM}[ ]${priority}${project}${component} ${subtask} ($today)"
   echo "LINE:"
   echo "$newtodo"
   [[ -z "$line" ]] && { echo "line blank!" ; exit 1; }
ex - "$TODO_FILE"<<!
${line}a
$newtodo
.
x
!
   
    if [  $? -eq 0 ]; then
       echo "Subtask added to Item $fullitem."
       cat "$TODO_FILE"
    else
       echo "Operation failed. "
    fi
    cleanup

}
subpriority ()
{
   item="$2"  # 
   newpri="$1"
   TAB="	" # tab
   errmsg="usage: $APPNAME priority [A-Z] #item"
   newpri=$( printf "%s\n" "$newpri" | tr 'a-z' 'A-Z' )
   [[ "$newpri" = @([A-Z]) ]] || die "$errmsg"
   validate_subtask "$item" "$errmsg"
   # if a priority exists, remove it. Remove only main task pri
   if grep -q "${TAB}\[.\] ([A-Z])" <<< "$todo"; then
      todo=$( echo "$todo" | sed 's/] ([A-Z]) /] /' )
   fi
   # add new priority exists
   todo=$( echo "$todo" | sed "s/] /] ($newpri) /" )
   sed -i.bak "/^ *- $item${TAB}/s/.*/$todo/" "$TODO_FILE"
   if [  $? -eq 0 ]; then
      echo "Change priority for $item successful"
   fi
   cleanup
}
subdepri ()
{
   item="$2"  # 
   newpri="$1"
   TAB="	" # tab
   errmsg="usage: $APPNAME priority [A-Z] #item"
   newpri=$( printf "%s\n" "$newpri" | tr 'a-z' 'A-Z' )
   [[ "$newpri" = @([A-Z]) ]] || die "$errmsg"
   validate_subtask "$item" "$errmsg"
   # if a priority exists, remove it. Remove only main task pri
   if grep -q "${TAB}\[.\] ([A-Z])" <<< "$todo"; then
      todo=$( echo "$todo" | sed 's/] ([A-Z]) /] /' )
      sed -i.bak "/^ *- $item${TAB}/s/.*/$todo/" "$TODO_FILE"
      if [  $? -eq 0 ]; then
         echo "Change priority for $item successful"
      fi
      cleanup
   fi
   # remove priority 
}
old_addsub ()
{
   item=$1
   errmsg="usage: $APPNAME addsub #item text"
   shift
   subtask="$*"
   validate_item "$item" "$errmsg"
   tasknum=$(echo "$todo" | awk -F'' '{ print NF;}')
   [ ! -z "$project" ] && project=" +${project}"
   [ ! -z "$component" ] && component=" @${component}"
   [ ! -z "$priority" ] && priority=" (${priority})"
   #newtext="${paditem}${DELIM}[ ]${priority}${project}${component} $text ($today)"
   newtodo="${todo}${item}.${tasknum} [ ]${priority}${project}${component} ${subtask} ($today)"
   sed -i.bak "/$paditem/s/.*/$newtodo/" "$TODO_FILE"
    if [  $? -eq 0 ]; then
       echo "Subtask added to Item $item."
    else
       echo "Operation failed. "
    fi
    cleanup
}
# ---------------------------------------------------------------------------- #
# delsub
# delete a subtask
# @param   : subtask id
# ---------------------------------------------------------------------------- #
delsub ()
{
   errmsg="usage: $APPNAME delsub ITEM#.SUBTASK#" # FIXME errmsgs in all sub cases
   fullitem="$1"  # rem _
   echo "item:$fullitem"
   validate_subtask "$fullitem" "$errmsg"
   [[ -z "$lineno" ]] && { die "Cant delete, no line number."; }
   sed -i.bak ${lineno}'d' "$TODO_FILE"
   if [  $? -eq 0 ]; then
       echo "Subtask $fullitem deleted."
   else
       echo "Operation failed. "
   fi
   delchildren "$fullitem"
   cleanup
   # note: i am leaving a C-a there, since there could be other subtasks
   # also, its required to keep the numbering going 
}

# ---------------------------------------------------------------------------- #
# check_file
# check if file exists
# ---------------------------------------------------------------------------- #
check_file ()
{
   [[ ! -f "$TODO_FILE" ]] && die "$TODO_FILE does not exist in this dir. Use 'add' to create an item first."
}

# ---------------------------------------------------------------------------- #
# subtask
# group of methods relating to subtasks (add, delete, mark)
# @param   : action
# @param   : item (not necessary)
# @return  : returns 
# ---------------------------------------------------------------------------- #
subtask ()
{
   action="$1"  # 
   #item="$2"  # 
   shift
   case $action in
      "del" | "delete")
         delsub "$@"
         ;;
      "add" | "a")
         addsub "$@"
         ;;
      "mark" | "status")
         marksub "$@"
         ;;
      "pri" | "priority")
         subpriority "$@"
         ;;
      "depri" )
         subdepri "$@"
         ;;
      * )
      echo "$action unknown. Please use one of add, del, mark." 1>&2   
      ;;
   esac
}





## ADD functions above
## -- getopts stuff -- ##
while [[ $1 = -* ]]; do
case "$1" in                    # remove _
   -P|--project)
      project="$2"
      shift 2
      ;;
   -C|--component)
      component="$2"
      shift 2
      ;;
   -p|--priority)
      priority="$2"
      shift 2
      ;;
   -v|--version)
     echo "$APPNAME version ${VERSION}, ${DATE}"
     echo "by $AUTHOR. This software is under the GPL License."
     exit
      ;;
   --colors)
     COLORIZE="1"
     shift
     ;;
   --no-colors)
     COLORIZE="0"
     shift
     ;;
   -h|--help|-help)
      help 
      exit
      ;;
   *)
      echo
      echo "Error: Unknown option: $1" >&2   # rem _
      echo
      usage
      exit 1
      ;;
esac
done
action=$( echo "$1" | tr 'A-Z' 'a-z' )
shift

case $action in
   "list")
      check_file
      list "$@" ;;
   "add")
      add "$@" ;;
   "mark" | "status")
      status "$@" ;;
   "pri" | "p")
      priority "$@" ;;
   "del" | "delete")
      delete "$@" ;;
   "depri" | "dep")
      depri "$@" ;;
   "subtask" | "sub")
      subtask "$@" ;;
   "tag" )
      tag "$@" ;;
   "help")
      help;;
   * )
   echo "Action incorrect. Actions include add, delete, list, mark." 1>&2
   usage
   ;;
esac
