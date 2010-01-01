#!/bin/bash
#*******************************************************#
#                      todoapp.sh                       #
#                 written by Rahul Kumar                #
#                    2009/12/14                         #
#           Yet another small, cute todo app            #
#           Licensed under GPL                          #
#           http://www.gnu.org/copyleft/gpl.html        #
#                                                       #
#    I wrote this script as a way of not completing     #
#    another, more pressing task.                       #
#                                                       #
#           v1.0.0 Initial Release                      #
#           v2.0.0 subtask in separate line             #
#*******************************************************#
# NOTE: the free-form text format, although tempting to start with
#+ gives problems when you wish to updates some term.
# Minimal installation, creates a file in the current
#+ folder, so you can have todo files in multiple projects

# the only configuration the user need do. The name of the output file
TODO_FILE="TODO2.txt"
ARCHIVE_FILE="oldtodo.txt"
COLORIZE=1   # if you want colored output, else comment out
COLOR_SCHEME=1 # colrize on priority, 2 is status
DEFAULT_ACTION="list"
# COLORIZE requires external file colors.sh in PATH
# get_serial_number required in path

FULLAPPNAME="$0"
APPNAME=$( basename $0 )
VERSION="2.2.6"
VERBOSE_FLAG=0
FORCE_FLAG=0
DATE="2009-12-29"
AUTHOR="rkumar"
today=$( date '+%Y-%m-%d' )
DELIM=$'\t'
TAB="	"
SUBGAP="  "
DATE_REGEX='[0-9]\{4\}-[0-9][0-9]-[0-9][0-9]'
SHOW_ALL=1
shopt -s extglob

USAGE=$( printf "%s\n        %s" "$APPNAME [--project PROJECT] [--component COMP] [--priority A-Z] add <text>" \
"     $APPNAME action TASK#" )
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
      add <text>
         add options:
         -P | --project <PROJECTNAME>  add project name to task
         -C | --component <COMPONENT> add component or context name to task
         -p | --priority <[A-Z]>  add priority to task
         e.g. todoapp.sh --project rms --component menu -p C "Menu needs date"

      addsub TASK# text
         Add a todo under TASK. Creates a subtask such as 1.1 or 1.1.1.

      delete TASK#
         Delete a task or subtask.

      mark | status TASK# <state> 
         Marks a task with given state.
         state - one of start,close, unstarted, pend, hold, next

      list
         Listing of tasks
         list options:
         --no-colors   don't show colors
         --colors      show colors
         --sort-serial sort on item number


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
item_exists () {
   item=$1 # sets item, globally
   # making interface friendlier, so one can script. 
   # In place of item, give last since we don't know last in a batch.
   if [[ "$item" = "last" ]]; then
      # derive last
      item=$( cut -c1-4 "$TODO_FILE" | sort -u -n -r | head -1 | tr -d '[:space:]' )
      last="$item"
   fi
   paditem=$( printf "%3s" $item )
   todo=$( grep -n "^$paditem" "$TODO_FILE" )
   if [[ -z "$todo" ]]; then
      return 1
   fi
   lineno=$( echo "$todo" | cut -d: -f1 )
   todo=$( echo "$todo" | cut -d: -f2 )
   ITEM_TYPE=1
   return 0
}

item_or_sub_exists ()
{
   item=$1
   item_exists $item
   if [  $? -eq 0 ]; then
      return 0
   fi
   subtask_exists $item
   [  $? -eq 0 ] && { return 0; }
   die "Error: $item does not exist. $errmsg"
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
   BAKFILE="${TODO_FILE}.bak"
   [ -f "$BAKFILE" ] && rm "$BAKFILE"
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
   # convert actual newline to C-a. slash n's are escapes so echo -e does not muck up.
   text=$( echo -n "$text" | tr '\n' '' | sed 's/\\/\\\\/g')
   appname=$( basename $( pwd ) )
   item=$( get_serial_number -a "$appname" -d "$(pwd)" )
   paditem=$( printf "%3s" $item )
   [ -z "$item" ] && { echo "Unexpected error! No task number to add"; exit 1; }
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
# # TODO --hide-complete
list ()
{
   #items=$( sort -t$'\t' -k2 "$TODO_FILE" )
   # join
   if [[ -n "$SORT_SERIAL" ]]; then
      sort_key="1"
   else
      sort_key="2"
   fi
   # added grep . to remove blank lines which were making sed hang
   if [[ "$SHOW_ALL" -eq 0 ]]; then
      regex='\[[^x]\]'
   else
      regex='.'
   fi
   items=$( grep "$regex" $TODO_FILE )
   [[ ! -z "$project" ]] && { items=$( echo "$items" | grep "+${project}" ) ; }
   [[ ! -z "$component" ]] && { items=$( echo "$items" | grep "@${component}" ) ; }
   [[ ! -z "$priority" ]] && { 
      if [[ $priority = "any" ]]; then
         priority="A-Z"
      fi
         # the extra [] allows use to pass 2 or more priorities such as AB or even
         #+ ^A.
         items=$( echo "$items" | grep "([${priority}])" ) ; 
   }


   # all remaining args are used to grep
   # if arg is preceded by hyphen, then search inverse (not matching).
   numargs=$#
   for ((i=1 ; i <= numargs ; i++)); do
      if [[ "${1:0:1}" = "-"  ]]; then
         items=$( echo "$items" | grep -v "${1:1}" )
      else
         items=$( echo "$items" | grep "$1" )
      fi
      shift
   done

   [[ -n "$HIDE_NUMBERING" || -n "$RENUMBER" ]] && {
       items=$( echo "$items" | cut -c4- | sed 's/^\( *- *\)[1-9][0-9\.]*/\1/' )
   }
   # join lines starting with hyphen, so sorting keeps subtasks with main task.
   # All lines starting with hyphen are joined with previous line using C-b
   items=$( echo "$items" | sed -e :a -e '$!N;s/\n\( *\)-/\1-/;ta' -e 'P;D' | sort -t'	' -k$sort_key  )
  
   [ -n "$RENUMBER" ] && { items=$( echo "$items" | nl -w4) ; }
   total=$( echo "$items" | wc -l ) 
   items=$( echo "$items" |  tr '' '\n' )
   #total=$( echo "$items" | wc -l ) 
   filter=""


   if [[ "$COLORIZE" = "1"  ]]; then
      #echo "INSIDE COLORIZE" 1>&2
      DEL="	"
      COL_BG_NORM=$(tput setab 9)
      COL_FG_NORM=$(tput setaf 9)
      COL_BG_RED=$( tput setab 1 )
      COL_FG_RED=$( tput setaf 1 )
      COL_BG_GREEN=$( tput setab 2 )
      . colors.sh ## XXX put path outside
      #items=$( echo "$items" | sed "s/\(\[[ 1]\]\)/${COL_BG_RED}\1${COL_BG_NORM}/" )
      # COL_FG_RED etc were not working in test environment for some reason... ah ! sh.
      #s/${DEL}\[x\]/${DEL}${COL_FG_RED}[x]${COL_FG_NORM}/g; \
      case $COLOR_SCHEME in
         1)
      items=$( echo "$items" \
      | sed "s/\[?\]/${COL_BG_RED}[ ]${COL_BG_NORM}/; \
      s/${DEL}\[x\]/${DEL}${COLOR_RED}[x]${COLOR_DEFAULT}/g; \
      s/${DEL}\[@\]/${DEL}${COLOR_GREEN}[@]${COLOR_DEFAULT}/g; \
      s/${DEL}\[H\]/${DEL}${COLOR_RED}[H]${COLOR_DEFAULT}/g; \
      s/${DEL}\[P\]/${DEL}${COLOR_RED}[P]${COLOR_DEFAULT}/g; \
      s/${DEL}\[1\]/${DEL}${COLOR_YELLOW}[1]${COLOR_DEFAULT}/g; \
      /\[ \] (A)/s/.*/${COLOR_YELLOW}&${COLOR_DEFAULT}/; \
      /\[ \] (B)/s/.*/${COLOR_WHITE}&${COLOR_DEFAULT}/; \
      /\[ \] (C)/s/.*/${COLOR_CYAN}&${COLOR_DEFAULT}/; \
      /\[ \] (D)/s/.*/${COLOR_GREEN}&${COLOR_DEFAULT}/; \
      /\[ \] ([E-Z])/s/.*/${COLOR_BROWN}&${COLOR_DEFAULT}/; \
      s/\[X\]/${COL_BG_RED}[1]${COL_BG_NORM}/" 
      )
            ;;
         2)
      items=$( echo "$items" \
      | sed "s/\[?\]/${COL_BG_RED}[ ]${COL_BG_NORM}/; \
      /${DEL}\[x\]/s/.*/${COLOR_BLUE}&${COLOR_DEFAULT}/; \
      /${DEL}\[@\]/s/.*/${COLOR_GREEN}&${COLOR_DEFAULT}/; \
      /${DEL}\[P\]/s/.*/${COLOR_RED}&${COLOR_DEFAULT}/; \
      /${DEL}\[H\]/s/.*/${COLOR_RED}&${COLOR_DEFAULT}/; \
      s/^\[X\]/${COL_BG_RED}[1]${COL_BG_NORM}/" 
      )
         ;;
      esac
   fi
   # taking care of subtasks
   echo -e "$items" | tr -s '' | sed "s//        /g;s/${TAB}/ /g" | tr '' '\n'
   #shown=$( echo "$items" | wc -l ) 
   #echo 
   #echo "Shown $shown of $total items from $TODO_FILE"
}
# ---------------------------------------------------------------------------- #
# delete
# delete an item based on number displayed on left
# @param   : item
# @return  : returns 
# ---------------------------------------------------------------------------- #
delete ()
{
   errmsg="usage: $APPNAME delete #item ..."
   if [  $# -eq 0 ]; then
      die "Item number required. $errmsg";
   fi
   numargs=$#
   for ((i=1 ; i <= numargs ; i++)); do
      item="$1"  # rem _
      #validate_item "$item" "$errmsg"
      item_or_sub_exists "$1" "$errmsg"
      if [[ $FORCE_FLAG -gt 0 ]]; then
         ans="Y"
      else
         echo -n "Do you wish to delete: $todo" '[y/n] ' ; read ans
      fi
      case "$ans" in
         y*|Y*) 
         #sed -i.bak "/^$paditem/d" "$TODO_FILE"
         sed  ${lineno}'!d' "$TODO_FILE" >> "$BAKFILE"
         sed -i.bak ${lineno}'d' "$TODO_FILE"
         if [  $? -eq 0 ]; then
            echo "$item: Delete successful."
            delchildren $item
         fi
         ;;
         *) echo "No item deleted"  ;;
      esac
      shift
   done
   
}
# ---------------------------------------------------------------------------- #
# priority
# Add a priority to a todo. Helps in sorting and coloring.
# @param   : item
# @param   : priority A-Z
# ---------------------------------------------------------------------------- #
priority ()
{
   # switched order to be consistent. Now item first. Sucks, I know.
   item="$1"  # 
   newpri="$2"
   TAB="	" # tab
   errmsg="usage: $APPNAME priority [A-Z] #item"
   newpri=$( printf "%s\n" "$newpri" | tr 'a-z' 'A-Z' )
   [[ "$newpri" = @([A-Z]) ]] || die "$errmsg"
   #validate_item "$item" "$errmsg"
   item_or_sub_exists  "$item" "$errmsg"
   # if a priority exists, remove it. Remove only main task pri
   if grep -q "${TAB}\[.\] ([A-Z])" <<< "$todo"; then
      todo=$( echo "$todo" | sed 's/] ([A-Z]) /] /' )
   fi
   # add new priority exists
   todo=$( echo "$todo" | sed "s/] /] ($newpri) /" )
   sed -i.bak $lineno"s/.*/$todo/" "$TODO_FILE"
   if [  $? -eq 0 ]; then
      echo "$item: priority set to $newpri."
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
   #validate_item "$item" "$errmsg"
   item_or_sub_exists  "$item" "$errmsg"
   # if a priority exists, remove it
   #if grep -q "\[.\] ([A-Z])" <<< "$todo"; then
   TAB="	" # tab
   if grep -q "${TAB}\[.\] ([A-Z])" <<< "$todo"; then
      todo=$( echo "$todo" | sed 's/] ([A-Z]) /] /' )
      sed -i.bak $lineno"s/.*/$todo/" "$TODO_FILE"
      if [  $? -eq 0 ]; then
         echo "$item: priority removed."
      fi
      cleanup
   else
      echo "$item: no priority."
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

    errmsg="usage: $APPNAME status TASK# [start|pend|close|hold|next|unstarted] "
    # making statuses more forgiving
    case "$status" in
       @|sta|star|start|started)
          status=start;;
       P|pen|pend|pending)
          status=pend;;
       x|clo|clos|close|closed)
          status=close;;
       1|next)
          status=next;;
       H|hold) status=hold;;
       u|uns|unst|unstart|unstarted) status=unstarted;;
       * )
          echo -n "$status: not a known status. Sure you wish to go ahead?" '[y/n] ' ; read ans
          case "$ans" in
             y*|Y*) : 
             ;;
             *) echo "No action taken."; die "$errmsg";;
          esac
       
       ;;
    esac
    newstatus=$( echo $status | sed 's/^start/@/;s/^pend/P/;s/^close/x/;s/hold/H/;s/next/1/;s/^unstarted/ /' )
    if [[ ${#newstatus} != 1 ]]; then
       echo "$newstatus: Status invalid."
       die "$errmsg"
    fi
    #validate_item "$item" "$errmsg"
    item_or_sub_exists "$item" "$errmsg"
    if grep -q "\[$newstatus\]" <<< "$todo"; then
       echo "$item: No action taken since already $status."
    else
       case $ITEM_TYPE in
          1)
             sed -i.bak "/^$paditem/s/\(.*\)\[.\]\(.*\)$/\1[$newstatus]\2/" "$TODO_FILE"
             if [[ $status = "close" ]]; then
                sed -i.bak ${lineno}"s/.*/& (x${today})/" "$TODO_FILE"
             fi
             ;;
          2)
             #sed -i.bak "/^ *-$SUBGAP$item/s/${item}${TAB}\[.\]/${item}${TAB}[$newstatus]/" "$TODO_FILE"
             sed -i.bak $lineno"s/${item}${TAB}\[.\]/${item}${TAB}[$newstatus]/" "$TODO_FILE"
             if [[ $status = "close" ]]; then
                sed -i.bak ${lineno}"s/.*/& (x${today})/" "$TODO_FILE"
             fi
             ;;
       * )
          ;;
       esac
       if [  $? -eq 0 ]; then
          echo "$item: Marked as $status"
       else
          echo "Operation failed. "
       fi
    fi
    markchildren "$item" $newstatus "$status"
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
   todo=$( grep -n "^ *-$SUBGAP$item${TAB}" "$TODO_FILE" )
   if [[ -z "$todo" ]]; then
      die "$item not found in $TODO_FILE. $errmsg"
   fi
   lineno=$( echo "$todo" | cut -d: -f1 )
   todo=$( echo "$todo" | cut -d: -f2 )
}
subtask_exists ()
{
   local item=$1
   todo=$( grep -n "^ *-$SUBGAP$item${TAB}" "$TODO_FILE" )
   if [[ -z "$todo" ]]; then
      return 1
   fi
   lineno=$( echo "$todo" | cut -d: -f1 )
   todo=$( echo "$todo" | cut -d: -f2 )
   ITEM_TYPE=2
   return 0
}

markchildren ()
{
   local item="$1"
   local status="$2" # now this contains the symbol
   local status_text="$3" # contains the original word
   if grep -q "^ *-$SUBGAP${item}\.[0-9\.]*${TAB}" "$TODO_FILE"; then
      :
   else
      return 0
   fi
   if [[ -z "$RECURSIVE_FLAG" ]]; then
      echo -n "Do you wish to mark subtasks of $item" '[y/n] ' ; read ans
      case "$ans" in
         y*|Y*) : ;;
         *) return 0;;
      esac
   fi
   
   [[ "$status_text" = "close" ]] && { 
   # the ^x prevents already closed item from getting date appended
      sed -i.bak "/^ *-$SUBGAP${item}\.[0-9\.]*${TAB}\[[^x]\]/s/.*/& (x${today})/" "$TODO_FILE"
   }
   sed -i.bak "/^ *-$SUBGAP${item}\.[0-9\.]*${TAB}/s/${TAB}\[.\]/${TAB}[$newstatus]/" "$TODO_FILE"
    if [  $? -eq 0 ]; then
       lines=$( diff "$TODO_FILE" "$TODO_FILE".bak | grep '^>' |  wc -l )
       [ $lines -gt 0 ] && echo "$lines subtasks of task $item marked as $status_text"
    else
       echo "Operation failed. "
    fi
}
## 1. 2009-12-24 18:03 added some kind of check to see if subtasks actually deleted
##+ to prevent false reporting. stat did not work since mod time between master and child
##+ was less than a second.
delchildren ()
{
   local item="$1"
   [[ "$item" = "last"  ]] && { echo "Error: delchildren got $item ." 1>&2; exit 1; }
   [[ -z "$item"  ]] && { echo "Error: delchildren got blank item ." 1>&2; exit 1; }
   sed "/^ *-$SUBGAP${item}\.[0-9\.]*${TAB}/!d" "$TODO_FILE" >> "$BAKFILE"
   lines1=$( wc -l $TODO_FILE )
   lines1=$(echo "${lines1%% *}" )
   sed -i.bak "/^ *-$SUBGAP${item}\.[0-9\.]*${TAB}/d" "$TODO_FILE"
   retval=$?
   lines2=$( wc -l $TODO_FILE )
   lines2=$(echo "${lines2%% *}" )
   removed=$(( lines1-lines2 )) 
   if [  $retval -eq 0 ]; then
      if [ "$lines1" != "$lines2" ]; then # 1.
         echo "$removed subtasks of task $item deleted"
      fi
   else
      echo "Operation failed. "
   fi
}

# ---------------------------------------------------------------------------- #
# addsub
# adds subtask below given task/subtask
# @param   : item
# @param   : text to add
# ---------------------------------------------------------------------------- #
addsub ()
{
   fullitem=$1
   shift
   subtask="$*"
   DELIM="${TAB}"
   #validate_item "$item" "$errmsg"
   #validate_subtask "$fullitem" "$errmsg"
   ## Is there a level below this one. Get the last one.
   if [[ "$fullitem" = "last" ]]; then
      # derive last
      fullitem=$( cut -c1-4 "$TODO_FILE" | sort -u -n -r | head -1 | tr -d '[:space:]' )
   fi
   full=$( grep -n -e "-$SUBGAP${fullitem}\.[0-9]*${TAB}" "$TODO_FILE" | tail -1 )
   ## extract number
      [[ $VERBOSE_FLAG -gt 0 ]] && echo "full:$full"
   if [[ -z "$full" ]]; then # no level below this one
      full=$( grep -n -e " ${fullitem}${TAB}" $TODO_FILE )
      [[ $VERBOSE_FLAG -gt 0 ]] && echo "2 full:$full"
      #prev=$(echo "$full" | cut -d'-' -f2 | grep -o '^ [0-9\.]\+' | tr -d '[:space:]' ) 
      prev=$(echo "$full" | grep -o -e " *[0-9\.]\+${TAB}" | sed "s/[ $TAB]//g") 
      [[ $VERBOSE_FLAG -gt 0 ]] && echo "prev: $prev."
      [[ -z "$prev" ]] && { echo "Error. Can't find $fullitem"; exit 1; }
      last="$prev"
      line=$( expr "$full" : '^\([0-9]\+\):' )
      #indent=$( expr "$full" : '^[0-9]\+:\( \+\)')
      indent=$( expr "$full" : '^[0-9]\+:\([^\[]\+\)')
      indent+="    "
      indent=$( echo "$indent" | sed 's/./ /g' )
      [[ $VERBOSE_FLAG -gt 0 ]] && echo "x${indent}y"
      newnum="${last}.1"
      [[ $VERBOSE_FLAG -gt 0 ]] && echo "newnum:$newnum"
      # get higher level
   else
      # there is a level below this one. get last.
      last=$(echo "$full" | cut -d'-' -f2 | grep -o '^  *[0-9\.]\+' | tr -d '[:space:]' ) 
      [[ $VERBOSE_FLAG -gt 0 ]] && echo "last:$last"
      [[ -z "$last" ]] && { die "Error 454: 'last' blank"; }
      # get line number of last
      lastchild=$( grep -n -e "-$SUBGAP${fullitem}\.[0-9]*\.[0-9]*" "$TODO_FILE" | tail -1 )
      if [[ -z "$lastchild" ]]; then
         line=$( expr "$full" : '^\([0-9]\+\):' )
      else
         line=$( expr "$lastchild" : '^\([0-9]\+\):' )
      fi
      indent=$( expr "$full" : '^[0-9]\+:\( \+\)')
      [ $? -gt 0 ] && die "Error 461: expr. possibly full blank"
      #indent=$( expr "$last" : '\([^-0-9]\+\)' )
      [[ $VERBOSE_FLAG -gt 0 ]] && {  
         echo "X${indent}Y"
         echo ""
         echo "last:$last"
      }
      highest=$( echo "$last" | cut -d' ' -f2 )
      [[ $VERBOSE_FLAG -gt 0 ]] && echo "line: $line, highest: $highest"
      base=$(expr $highest : '.*\.\([0-9]\+\)$')
      [ $? -gt 0 ] && die "Error 469: expr. possibly highest blank"
      len=$(( ${#highest}-${#base}-0 ))
      [[ $VERBOSE_FLAG -gt 0 ]] && echo "len: $len"
      part1="${highest:0:${len}}"
      (( base++ ))
      [[ $VERBOSE_FLAG -gt 0 ]] && echo "next: $base, ${part1}.${base}"
      newnum="${part1}.${base}"
      newnum=$( echo $newnum | tr -s '\.' )
      [[ $VERBOSE_FLAG -gt 0 ]] && echo "2 newnum:$newnum"
   fi
   [ ! -z "$project" ] && project=" +${project}"
   [ ! -z "$component" ] && component=" @${component}"
   [ ! -z "$priority" ] && priority=" (${priority})"
   #newtext="${paditem}${DELIM}[ ]${priority}${project}${component} $text ($today)"
   if [[ -z "$COPYING" ]]; then
      subtask=$( echo -n "$subtask" | tr '\n' '' | sed 's/\\/\\\\/g')
   fi
   newtodo="${indent}-  ${newnum}${DELIM}[ ]${priority}${project}${component} ${subtask}"
   # if there's no date at end, add todays. User may send in own start date, or copy may
   if grep -q "([0-9]\{4\}-[0-9][0-9]-[0-9][0-9])$" <<< "$subtask"; then
      :
   else
      newtodo+=" ($today)"
   fi
   [[ $VERBOSE_FLAG -gt 0 ]] && { echo "LINE:"
      echo "$newtodo"
   }
   [[ -z "$line" ]] && { echo "line blank!" ; exit 1; }
ex - "$TODO_FILE"<<!
${line}a
$newtodo
.
x
!
   
    if [  $? -eq 0 ]; then
       echo "Added $newnum to $TODO_FILE"
       RESULT="$newnum"
       #cat "$TODO_FILE"
    else
       echo "Operation failed. "
       RESULT=
    fi
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
# renumber
# Renumbers one task to another. Only top level task
# @param   : from_item
# @param   : to_item
# @return  : zilch on success, 1 on error
# ---------------------------------------------------------------------------- #
renumber ()
{
   # only for top level task
   errmsg="Usage: renumber FROM_TASK# TO_TASK# (Note: from and to are top level tasks"
   from_item=$1
   to_item=$2
   [[ "$from_item" = +([0-9]) ]] || die "Item should be a top level task. $errmsg"
   [[ "$to_item" = +([0-9]) ]] || die "To_Item should be numeric. $errmsg"
   item_exists $from_item
   [[ $? -eq 1  ]] && { 
      #subtask_exists $from_item
      #[[ $? -eq 1  ]] && { die "Error: $from_item does not exist."; }
      die "Error: $from_item does not exist."; 
   }
   [[ $VERBOSE_FLAG -gt 0 ]] && echo "   OK. $from_item exists $todo"
   old_todo="$todo"
   item_exists $to_item
   [[ $? -eq 0  ]] && { die "Error: $to_item already exists."; }
   #subtask_exists $to_item
   #[[ $? -eq 0  ]] && { die "Error: $to_item already exists."; }
   [[ $VERBOSE_FLAG -gt 0 ]] && echo "   all seems okay...:$old_todo"
   f_item=$( printf "%3s" $from_item )
   t_item=$( printf "%3s" $to_item )
   sed -i.bak "/${f_item}.*${TAB}\[.\]/s/${f_item}/${t_item}/" "$TODO_FILE"
   echo "$from_item renumbered to $to_item"
#   sed -i.bak "/${from_item}\.[0-9\.]*${TAB}\[.\]/s/${from_item}/${to_item}/" "$TODO_FILE"
}
# ---------------------------------------------------------------------------- #
# copyunder
# copies one task under another task. Useful for demoting a task, so multiple
#+ tasks can be grouped under one head task.
# @param   : from_item
# @param   : to_item
# @return  : 0 
# ---------------------------------------------------------------------------- #
copyunder ()
{
   # the sed match will fail with a 3 digit number in top level task FIXME
   from_item=$1
   to_item=$2
   # extract text of mentioned item, but i seem to be removing everything upto the state
   #+ which means copied version will have open state.
   text=$( sed -n "/ ${from_item}${TAB}\[.\]/s/^.*\] //p" "$TODO_FILE" )
   [[ -z "$text" ]] && { die "Error! Could not get item text"; }
   COPYING=1
   addsub $to_item "$text"
   echo "Copied $from_item to $RESULT"
}
# ---------------------------------------------------------------------------- #
# edit
# Edit a given task text. Useful for changing, or when a task has been demoted
#+ to edit the top-level entry.
# @param   : item (to edit)
# ---------------------------------------------------------------------------- #
edit ()
{

   local item="$1"
   todo=$( grep -n " $item${TAB}" "$TODO_FILE" )
   [[ -z "$todo" ]] && { die "$item: no such item or subtask"; }
   ## take out the stuffing between status and date
   text=$( expr "$todo" : '.*\[.\] \(.*\) ([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\})$' )
   text=$( expr "$todo" : '.*\[.\] \(.*\)$' )
   [[ -z "$text" ]] && { die "Sorry could not extract text"; }
   TMPFILE=${TMPDIR:-/tmp}/prog.$$
   trap "rm -f $TMPFILE; exit 1" 0 1 2 3 13 15
   echo "$text" > "$TMPFILE"
   edit_tmpfile
   if [  $? -eq 0 ]; then
      lineno=$(echo "$todo" | cut -d: -f1)
      [[ -z "$lineno" ]] && { die "Program error. Could not find lineno"; }
      text=$( cat "$TMPFILE" )
      echo "line:$lineno."
      echo "-->s/\].*/] $text/" 
      sed -i.bak $lineno"s/\].*/] $text/" "$TODO_FILE"
      if [  $? -eq 0 ]; then
         echo "Operation successful"
      else
         echo "Operation failed"
      fi
   fi
   rm "$TMPFILE"
   trap 0
}

## Used to edit multi-line text
## edits temporary file
# @return = 0 on success, 1 if canceled
edit_tmpfile()
{
            mtime=`stat -c %Y $TMPFILE`
            $EDITOR $TMPFILE
            mtime2=`stat -c %Y $TMPFILE`
            if [ $mtime2 -gt $mtime ] 
            then
                
                ## added cleaning of possible non-print chars
                TMPFILE2=${TMPDIR:-/tmp}/prog2.$$
                tr -cd '\12\15\40-\176'  < $TMPFILE > $TMPFILE2
                mv $TMPFILE2 $TMPFILE
                return 0
            else
                echo "editing cancelled" 1>&2
                RESULT=0
            fi
            return 1
}

# ---------------------------------------------------------------------------- #
# redo
# Renumbers the entire file, starting 1.
# Useful when the numbers have gone high, many tasks have been deleted
#+ and you want to start again from 1.
# This updates the serial_number file.
# ---------------------------------------------------------------------------- #
redo ()
{
   # join
   #items=$( sed -e :a -e '$!N;s/\n\( *\)-/~\1-/;ta' -e 'P;D' "$TODO_FILE" | cut -c4-  | nl -w3 | tr '~' '\n' )
   #echo -e "$items" | tr -s '' | sed 's//        /g;s/	/ /g' | tr '' '\n'

   TMPFILE="TMPFILE.$$"
   BAKFILE="$TODO_FILE".bak.$today
   cp "$TODO_FILE" "$BAKFILE"
   > "$TMPFILE"
   appname=$( basename $( pwd ) )
   get_serial_number -a "$appname" -d "$(pwd)" -z
   actnum=( $( cut -c1-3 $TODO_FILE | grep '[0-9]' | sort -n | tr -d ' ' ) )
   len="${#actnum[@]}"
   #echo "len $len" 1>&2
   for (( i = 1; i <= $len; i++ )); do
      item=$( get_serial_number -a "$appname" -d "$(pwd)" -s 1 )
      from_item="${actnum[i-1]}"
      to_item=$item
      from_item=$( printf "%3s" $from_item )
      to_item=$( printf "%3s" $to_item )
      if [[ $item -eq ${actnum[i-1]} ]]; then
         grep "${from_item}${TAB}" "$TODO_FILE" >> "$TMPFILE"
         grep "${from_item}\..*${TAB}" "$TODO_FILE" >> "$TMPFILE"
         continue
      fi
      echo "renumber ${actnum[i-1]} $item" 1>&2
      #renumber ${actnum[i-1]} $item
      #sed -i.bak "/${from_item}.*${TAB}\[.\]/s/${from_item}/${to_item}/" "$TODO_FILE"
      sed -n "/${from_item}${TAB}\[.\]/s/${from_item}/${to_item}/p" "$TODO_FILE" >> "$TMPFILE"
      sed -n "/${from_item}\..*${TAB}\[.\]/s/${from_item}/${to_item}/p" "$TODO_FILE" >> "$TMPFILE"
   done
   cp "$TMPFILE" "$TODO_FILE"
   echo "Operation complete." 
   echo "Backup saved as $BAKFILE." 
   rm "$TMPFILE"
}

# ---------------------------------------------------------------------------- #
# tag
# add a tag to an item
# @param   : item item number
# @param   : tag tag to add, like a keyword
# @return  : 0 
# ---------------------------------------------------------------------------- #
tag ()
{
   errmsg="Usage: $APPNAME tag ITEM# <tag>"
   item="$1"  # item number 
   tag="$2"  # tag to add, like a keyword 
   [[ -z "$tag" ]] && { echo "Error: tag blank." 1>&2; exit 1; }
   item_or_sub_exists "$item" "$errmsg"
   if grep -q "@$tag" <<< "$todo"; then
      echo "$item already tagged with $tag."
   else
      todo=$( echo "$todo" | sed "s/ \(([0-9]\{4\}\)/ @$tag \1/" )
      sed -i.bak $lineno"s/.*/$todo/" "$TODO_FILE"
      if [  $? -eq 0 ]; then
         echo "$item: added tag $tag"
      fi
      cleanup
   fi
}

# ---------------------------------------------------------------------------- #
# note
# Add a note to a task or subtask
# Adds a note before the start date, prepended with a C-a. The C-a
# results in a newline when printing.
# @param   : task task id
# @param   : text text to add
# @return  : 0 or 1   
# added 2009-12-29 14:43 
# @since 2.2.6
# ---------------------------------------------------------------------------- #
note ()
{
   errmsg="Usage: $APPNAME note ITEM# <text>"
   item="$1"  # item number 
   text="$2"  # text to add 
   [[ -z "$text" ]] && { echo "Error: note blank. $errmsg" 1>&2; exit 1; }
   item_or_sub_exists "$item" "$errmsg"
   indent=$( expr "$todo" : '^\( *\)' )
   todo=$( echo "$todo" | sed "s/ \(([0-9]\{4\}\)/ ${indent}* ${text} \1/" )
   [  $? -ne 0 ] && die "Error in replacement -- cannot proceed. Possibly slash in text. Try *escaping* it.";
   #sed -i.bak $lineno"s/.*/$todo/" "$TODO_FILE"
   change_line "$todo"
   if [  $? -eq 0 ]; then
      echo "$item: added note."
   else
      echo "Error. Pls check backup"
   fi
}

##
## change a line in file based on lineno
##
change_line ()
{
   text="$@"
ex - "$TODO_FILE"<<!
${lineno}c
$text
.
x
!
}


# ---------------------------------------------------------------------------- #
# guess_error
# try to give a friendly message to user guessing what he might
#+ have been attempting
# @param   : param1 desc
# @param   : param2 desc
# @return  : returns 
# ---------------------------------------------------------------------------- #
guess_error ()
{
   if grep -q "^[1-9]" <<< "$action"; then
      echo "*** Task Id usually given immediately AFTER action ***" 1>&2
   fi
   if [[ ! -z "$project" ]]; then
      echo "You may have been trying 'add' or forgotten to provide an argument" 1>&2
   fi
   if [[ ! -z "$component" ]]; then
      echo "You may have been trying 'add' or forgotten to provide an argument" 1>&2
   fi
}

# displays last added task number (top level).
# This does not return last added subtask
highest ()
{
   cut -c1-4 "$TODO_FILE" | sort -u -n -r | head -1 | tr -d '[:space:]' 
}

# ---------------------------------------------------------------------------- #
# archive
# copies off completed tasks to archive.txt
# @param   : item item numbers or 'completed'/'closed'
# @return  : 0 or 1
# ---------------------------------------------------------------------------- #
archive ()
{
   items="$@"  # item numbers or 'completed'/'closed' rem _
   [[ -z "$items" ]] && { items="closed";}
   # This is simple and easy but moves off subitems too
   # They would get separated from top level task in archive
   #+ file.
   ## sed "/${TAB}\[x\]/!d" "$TODO_FILE" >> "$ARCHIVE_FILE"

   FORCE_FLAG=1 # don't prompt when deleting
   # select main tasks that are completed. We assume their
   #+ subtasks are complete too.
   case "$items" in
      closed|comp|complete|completed)
      items=$( grep "^ *[0-9][0-9]*${TAB}\[x\] " "$TODO_FILE" | cut -c1-4 )
         ;;
   esac
   [[ -z "$items" ]] && { echo "Nothing to archive."; exit 0; }
   #echo "closed:$items"
   declare i ctr=0
   for ite in "$items"; do
      #echo "$ite ..."
      delete $ite > /dev/null
      if [ $? -eq 0 ]; then 
         echo "$ite: archived"
         (( ctr++ ))
      fi
   done
   if [ $? -eq 0 ]; then
      [ $ctr -gt 0 ] && echo "Archived $ctr completed/closed tasks to $ARCHIVE_FILE"
   fi
}



## ADD functions above
## -- getopts stuff -- ##
while [[ $1 = -* ]]; do
case "$1" in                    # remove _
   -d) dir=$2
      shift 2
      if [ -d "$dir" ]; then
         cd "$dir"
      else
         die "$dir: no such directory"
      fi
   ;;
   -A|--show-all)
      # option for list. to show all records, even completed (justin case default changes later)
      SHOW_ALL=1
      shift;;
   -x|--hide-completed)
      # option for list, to show all but completed
      HIDE_COMPLETED=1
      SHOW_ALL=0
      shift;;
   --hide-numbering)
      # option for list, to hide numbering, since default sorts on priority which if not set
      # sorts on task name.
      HIDE_NUMBERING=1
      shift;;
   --renumber)
      # option for list, to hide numbering, since default sorts on priority which if not set
      # sorts on task name.
      RENUMBER=1
      shift;;
   -P|--project)
      project="$2"
      [[ "${2:0:1}" = "-" ]] && { echo "Possible missing project name"; }
      shift 2
      ;;
   -C|--component)
      component="$2"
      [[ "${2:0:1}" = "-" ]] && { echo "Possible missing component name"; }
      shift 2
      ;;
   -p|--priority)
      priority="$2"
      [[ "${2:0:1}" = "-" ]] && { echo "Possible missing priority"; }
      shift 2
      ;;
   -v|--version)
     echo "$APPNAME version ${VERSION}, ${DATE}"
     echo "by $AUTHOR. This software is under the GPL License."
     exit
      ;;
   --color|--colors)
     COLORIZE="1"
     COLOR_SCHEME=1
     shift
     ;;
   --no-color|--no-colors)
     COLORIZE="0"
     shift
     ;;
   --sort-serial)
     SORT_SERIAL=1
     shift
     ;;
   --color-scheme)
     COLORIZE="1"
      case $2 in
         priority)
            COLOR_SCHEME=1;;
         status)
            COLOR_SCHEME=2;;
         * )
            COLOR_SCHEME=1;;
      esac
      shift 2
      ;;
   -h|--help|-help)
      help 
      exit
      ;;
   -V|--verbose)
      (( VERBOSE_FLAG+=1 ))
     shift
     ;;
   -R|--recursive)
     RECURSIVE_FLAG=1
     shift
     ;;
   --force)
     FORCE_FLAG=1
     shift
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
[[ -z "$action" ]] && {  action="$DEFAULT_ACTION"; }
case $action in
   "list")
      check_file
      list "$@" ;;
   "add")
      add "$@" ;;
   "mark" | "status")
      status "$@" ;;
   "sta" | "start" )
     # short cut to start a task. Just do: todoapp.sh sta 10
      status "$1" "start" ;;
   "clo" | "close" )
     # short cut to close a task. Just do: todoapp.sh clo 10
      status "$1" "close" ;;
   "p" | "pri" )
      priority "$@" ;;
   "del" | "delete")
      BAKFILE="deltodo.txt"
      delete "$@" 
      cleanup;;
   "dep" | "depri")
      depri "$@" ;;
   "addsub" | "subadd")
      addsub "$@" 
      cleanup;;
   #"sub" | "subtask")
      #subtask "$@" ;;
   "tag" )
      tag "$@" ;;
   "renum" | "renumber" )
      renumber "$@" 
      cleanup;;
   "cu" | "copyunder" )
      copyunder "$@" ;;
   "edit")
      edit "$@" ;;
   "redo" )
      redo;;
   "highest" )
      highest;;
   "help")
      help;;
   "archive")
      BAKFILE="$ARCHIVE_FILE"
      archive "$@" ;;
   "addnote" | "note")
      note "$@" && cleanup
      ;;
   * )
   guess_error "$@"
   echo "Action ($action) incorrect. Actions include add, addsub, delete, list, mark, priority." 
   usage
   ;;
esac
