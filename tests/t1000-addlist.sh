#!/bin/sh

#rm serial_numbers
#rm TODO2.txt
test_description='basic add and list functionality

This test just makes sure the basic add and list
command work.
'
. ./test-lib.sh

#
# Add and list
#
test_todo_session 'basic add/list' <<EOF
>>> todoapp.sh add Adding first task 1
Added 1 to TODO2.txt

>>> todoapp.sh list
  1 [ ] Adding first task 1 (2009-02-13)

>>> todoapp.sh addsub 1 "Adding first sub-task 1.1"
Added 1.1 to TODO2.txt

>>> todoapp.sh addsub 1 "Adding 2nd sub-task 1.2"
Added 1.2 to TODO2.txt

>>> todoapp.sh add "Adding second task 2"
Added 2 to TODO2.txt

>>> todoapp.sh addsub 2 "Adding first sub-task 2.1"
Added 2.1 to TODO2.txt

>>> todoapp.sh addsub 2.1 "Adding first sub-task 2.1.1"
Added 2.1.1 to TODO2.txt

>>> todoapp.sh addsub 2.1 "Adding 2nd sub-task 2.1.2"
Added 2.1.2 to TODO2.txt

>>> todoapp.sh list
  1 [ ] Adding first task 1 (2009-02-13)
        -  1.1 [ ] Adding first sub-task 1.1 (2009-02-13)
        -  1.2 [ ] Adding 2nd sub-task 1.2 (2009-02-13)
  2 [ ] Adding second task 2 (2009-02-13)
        -  2.1 [ ] Adding first sub-task 2.1 (2009-02-13)
                   -  2.1.1 [ ] Adding first sub-task 2.1.1 (2009-02-13)
                   -  2.1.2 [ ] Adding 2nd sub-task 2.1.2 (2009-02-13)

EOF

test_todo_session 'mark' <<EOF
>>> todoapp.sh mark 1.1 start
1.1: Marked as start

>>> todoapp.sh mark 1.2 start
1.2: Marked as start

>>> todoapp.sh --recursive mark 2 start
2: Marked as start
Subtasks of Item 2 marked as start

>>> todoapp.sh --recursive mark 2 start
2: No action taken since already start.
Subtasks of Item 2 marked as start

>>> todoapp.sh list
  1 [ ] Adding first task 1 (2009-02-13)
        -  1.1 [@] Adding first sub-task 1.1 (2009-02-13)
        -  1.2 [@] Adding 2nd sub-task 1.2 (2009-02-13)
  2 [@] Adding second task 2 (2009-02-13)
        -  2.1 [@] Adding first sub-task 2.1 (2009-02-13)
                   -  2.1.1 [@] Adding first sub-task 2.1.1 (2009-02-13)
                   -  2.1.2 [@] Adding 2nd sub-task 2.1.2 (2009-02-13)

EOF
test_done
