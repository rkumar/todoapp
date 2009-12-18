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


## License

Under GNU GPL License
Written by rkumar.

## Usage

  Usage: todoapp.sh [--project PROJECT] [--component COMP] [--priority A-Z] add <text>
         todoapp.sh <action> ITEM#

**  Actions:**
  add
     [suboptions] add "todo item"
     add suboptions:
     -P | --project  add project name to item
     -C | --component add component or context name to item
     -p | --priority  add priority to item

  delete
     delete #ITEM
     Deletes item and child items

  mark | status #ITEM <state> 
     Change the state of the given item to <state>
     state - one of start,close, unstarted, pend, hold, next

  list
     Listing of tasks
     list sub-options:
     --no-colors  don't show colors
     --colors     show colors

  addsub ITEM# [args]
     add ITEM# text
     Add a subtask to the given item/subtask with given text

  renumber ITEM# ITEM#
    Renumber a top level item to another (empty/deleted) number
    (e.g renumber 24 12)

  redo
    Renumber the entire file starting 1. This is useful if you have been
    using the todo file for a long time, and you now have high numbers.

  copyunder | cu ITEM# ITEM#
    Copy an existing item as a subtask of another (or same) item.
    This does not work recursively.

  edit ITEM#
    Edit the text of an item in EDITOR.

*Note:* the subtask subcommand will probably be removed soon. del, mark etc will work
for both top-level and lower-level tasks. "addsub" will be required.
## 
