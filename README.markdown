# todoapp

A simple, multi-level command-line todo list manager.  
Based on bash.

## License

Under GNU GPL License
Written by rkumar.

## Usage

  Usage: todoapp.sh [--project PROJECT] [--component COMP] [--priority A-Z] action #ITEM

**  Actions:**
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

## 
