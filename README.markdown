# todoapp

An unbelievably complex, multi-level command-line todo list manager.  
Based on bash.

    "I wrote this script as a way of not completing another, more pressing task."
-- <http://quandyfactory.com/blog/1/productivity_and_procrastination>

### Reviews

"An unbelievably useless and ridiculous piece of ****!"

"A Todo-list on steroids"

"I'll never use another todo-list manager ever again."

"This software blew my pants off!!!!"

"Downright frivolous."


## License

Under GNU GPL License  

Written by rkumar.

## Usage

  Usage: todoapp.sh [--project PROJECT] [--component COMP] [--priority A-Z] add <text>
         todoapp.sh <action> TASK#

**  Actions:**
  add
     [suboptions] add "todo item"
     add suboptions:
     -P | --project  add project name to item
     -C | --component add component or context name to item
     -p | --priority  add priority to item

  delete
     delete TASK#
     Deletes item and child items
     --force  does not prompt user

  mark | status TASK# <state> 
     Change the state of the given item to <state>
     state - one of start,close, unstarted, pend, hold, next
     --recursive  changes state of subtasks without prompting

  list [search-terms]
     Listing of tasks
     list sub-options:
     --no-colors  - don't show colors
     --colors     - show colors  (default)
     --color-scheme priority  - show priorities in separate colors (default)
     --color-scheme status  - show statuses in separate colors
     --sort-serial  - sorts on task id rather than priority
     --hide-completed - do not list completed tasks
     --show-all - show all tasks (default)
     -P | --project <name> - show for this project only
     -C | --component <name> - show for this component only
     -p | --priority <name> - show for this priority 
        examples: -p any, -p A, -p AB, -p A-C, -p ^A
     --hide-numbering - do not show numbers on left
     --renumber - numbers top level tasks after sorting (these are temporary numbers)

  addsub TASK# [args]
     addsub TASK# text
        Add a subtask to the given item/subtask with given text
     addsub last text
        Adds text as a subtask under highest task (useful when adding from script)

  renumber TASK# TASK#
    Renumber a top level task to another (empty/deleted) number
    (e.g renumber 24 12)

  redo
    Renumber the entire file starting 1. This is useful if you have been
    using the todo file for a long time, and you now have high numbers.

  copyunder | cu TASK# TASK#
    Copy an existing task as a subtask of another (or same) task.
    This does not work recursively.

  edit TASK#
    Edit the text of a task in EDITOR.

  tag TASK# <tag>
    Add a keyword or tag to a task

  archive
    move closed tasks to archive.txt
    archive TASK# ...
       archive the given tasks to archive.txt

  note TASK# <text>
     add a note to a task. This could be what you actually did.

  clo|close <TASK>
     shortcut to close a task
  sta|start <TASK>
     shortcut to start a task
   
**Other options:**
  -d <dirname>   : name of directory to work in
                   Useful to create aliases for other directories


**Other settings:**

DEFAULT_ACTION  : action to run, if none mentioned. default is 'list'.

Note: the end of todoapp.sh will contain the latest
actions and options that may not have been updated here.

##  Screenshots

![listing](http://i47.tinypic.com/keuetg.jpg)

![listing2](http://i47.tinypic.com/1t66v5.jpg)

## Install

Copy the 3 .sh files to a folder in your path, and run todoapp.sh.
If you've pressed the download button on git, the tar should contain a makefile
along with a tests directory. You can run `make test` and run the 80+
tests.
