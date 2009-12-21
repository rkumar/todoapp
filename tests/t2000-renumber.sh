#!/bin/sh

test_description='copyunder renumber 

'
. ./test-lib.sh

#
# Add and list
#

cat > TODO2.txt << EOF
  1	[ ] Adding first task 1 (2009-02-13)
        -  1.1	[@] Adding first sub-task 1.1 (2009-02-13)
        -  1.2	[@] Adding 2nd sub-task 1.2 (2009-02-13)
  3	[ ] Adding task 3 (2009-02-13)
        -  3.1	[ ] Adding first sub-task 3.1 (2009-02-13)
        -  3.2	[ ] Adding 2nd sub-task 3.2 (2009-02-13)
                   -  3.2.1	[ ] Adding 2nd sub-task 3.2.1 (2009-02-13)
  2	[@] Adding second task 2 (2009-02-13)
        -  2.1	[@] Adding first sub-task 2.1 (2009-02-13)
                   -  2.1.1	[@] Adding first sub-task 2.1.1 (2009-02-13)
                   -  2.1.2	[@] Adding 2nd sub-task 2.1.2 (2009-02-13)
EOF
echo "$(basename $(pwd)):4" >> serial_numbers
test_todo_session 'renumber and redo' <<EOF

>>> todoapp.sh add "created this to move under another (4)"
Added 4 to TODO2.txt

>>> todoapp.sh --no-colors list
  1 [ ] Adding first task 1 (2009-02-13)
        -  1.1 [@] Adding first sub-task 1.1 (2009-02-13)
        -  1.2 [@] Adding 2nd sub-task 1.2 (2009-02-13)
  3 [ ] Adding task 3 (2009-02-13)
        -  3.1 [ ] Adding first sub-task 3.1 (2009-02-13)
        -  3.2 [ ] Adding 2nd sub-task 3.2 (2009-02-13)
                   -  3.2.1 [ ] Adding 2nd sub-task 3.2.1 (2009-02-13)
  4 [ ] created this to move under another (4) (2009-02-13)
  2 [@] Adding second task 2 (2009-02-13)
        -  2.1 [@] Adding first sub-task 2.1 (2009-02-13)
                   -  2.1.1 [@] Adding first sub-task 2.1.1 (2009-02-13)
                   -  2.1.2 [@] Adding 2nd sub-task 2.1.2 (2009-02-13)

>>> todoapp.sh addsub 2.1 "created this to move under another (2.1.x)"
Added 2.1.3 to TODO2.txt

>>> todoapp.sh --no-colors list
  1 [ ] Adding first task 1 (2009-02-13)
        -  1.1 [@] Adding first sub-task 1.1 (2009-02-13)
        -  1.2 [@] Adding 2nd sub-task 1.2 (2009-02-13)
  3 [ ] Adding task 3 (2009-02-13)
        -  3.1 [ ] Adding first sub-task 3.1 (2009-02-13)
        -  3.2 [ ] Adding 2nd sub-task 3.2 (2009-02-13)
                   -  3.2.1 [ ] Adding 2nd sub-task 3.2.1 (2009-02-13)
  4 [ ] created this to move under another (4) (2009-02-13)
  2 [@] Adding second task 2 (2009-02-13)
        -  2.1 [@] Adding first sub-task 2.1 (2009-02-13)
                   -  2.1.1 [@] Adding first sub-task 2.1.1 (2009-02-13)
                   -  2.1.2 [@] Adding 2nd sub-task 2.1.2 (2009-02-13)
                   -  2.1.3 [ ] created this to move under another (2.1.x) (2009-02-13)

>>> todoapp.sh cu 4 4
Added 4.1 to TODO2.txt
Copied 4 to 4.1

>>> todoapp.sh --no-colors list
  1 [ ] Adding first task 1 (2009-02-13)
        -  1.1 [@] Adding first sub-task 1.1 (2009-02-13)
        -  1.2 [@] Adding 2nd sub-task 1.2 (2009-02-13)
  3 [ ] Adding task 3 (2009-02-13)
        -  3.1 [ ] Adding first sub-task 3.1 (2009-02-13)
        -  3.2 [ ] Adding 2nd sub-task 3.2 (2009-02-13)
                   -  3.2.1 [ ] Adding 2nd sub-task 3.2.1 (2009-02-13)
  4 [ ] created this to move under another (4) (2009-02-13)
        -  4.1 [ ] created this to move under another (4) (2009-02-13)
  2 [@] Adding second task 2 (2009-02-13)
        -  2.1 [@] Adding first sub-task 2.1 (2009-02-13)
                   -  2.1.1 [@] Adding first sub-task 2.1.1 (2009-02-13)
                   -  2.1.2 [@] Adding 2nd sub-task 2.1.2 (2009-02-13)
                   -  2.1.3 [ ] created this to move under another (2.1.x) (2009-02-13)

>>> todoapp.sh cu 4 2
Added 2.2 to TODO2.txt
Copied 4 to 2.2

>>> todoapp.sh --no-colors list
  1 [ ] Adding first task 1 (2009-02-13)
        -  1.1 [@] Adding first sub-task 1.1 (2009-02-13)
        -  1.2 [@] Adding 2nd sub-task 1.2 (2009-02-13)
  3 [ ] Adding task 3 (2009-02-13)
        -  3.1 [ ] Adding first sub-task 3.1 (2009-02-13)
        -  3.2 [ ] Adding 2nd sub-task 3.2 (2009-02-13)
                   -  3.2.1 [ ] Adding 2nd sub-task 3.2.1 (2009-02-13)
  4 [ ] created this to move under another (4) (2009-02-13)
        -  4.1 [ ] created this to move under another (4) (2009-02-13)
  2 [@] Adding second task 2 (2009-02-13)
        -  2.1 [@] Adding first sub-task 2.1 (2009-02-13)
                   -  2.1.1 [@] Adding first sub-task 2.1.1 (2009-02-13)
                   -  2.1.2 [@] Adding 2nd sub-task 2.1.2 (2009-02-13)
                   -  2.1.3 [ ] created this to move under another (2.1.x) (2009-02-13)
        -  2.2 [ ] created this to move under another (4) (2009-02-13)

>>> todoapp.sh cu 4 2.1
Added 2.1.4 to TODO2.txt
Copied 4 to 2.1.4

>>> todoapp.sh --no-colors list
  1 [ ] Adding first task 1 (2009-02-13)
        -  1.1 [@] Adding first sub-task 1.1 (2009-02-13)
        -  1.2 [@] Adding 2nd sub-task 1.2 (2009-02-13)
  3 [ ] Adding task 3 (2009-02-13)
        -  3.1 [ ] Adding first sub-task 3.1 (2009-02-13)
        -  3.2 [ ] Adding 2nd sub-task 3.2 (2009-02-13)
                   -  3.2.1 [ ] Adding 2nd sub-task 3.2.1 (2009-02-13)
  4 [ ] created this to move under another (4) (2009-02-13)
        -  4.1 [ ] created this to move under another (4) (2009-02-13)
  2 [@] Adding second task 2 (2009-02-13)
        -  2.1 [@] Adding first sub-task 2.1 (2009-02-13)
                   -  2.1.1 [@] Adding first sub-task 2.1.1 (2009-02-13)
                   -  2.1.2 [@] Adding 2nd sub-task 2.1.2 (2009-02-13)
                   -  2.1.3 [ ] created this to move under another (2.1.x) (2009-02-13)
                   -  2.1.4 [ ] created this to move under another (4) (2009-02-13)
        -  2.2 [ ] created this to move under another (4) (2009-02-13)

>>> todoapp.sh cu 2.1.3 2.1
Added 2.1.5 to TODO2.txt
Copied 2.1.3 to 2.1.5

>>> todoapp.sh --no-colors list
  1 [ ] Adding first task 1 (2009-02-13)
        -  1.1 [@] Adding first sub-task 1.1 (2009-02-13)
        -  1.2 [@] Adding 2nd sub-task 1.2 (2009-02-13)
  3 [ ] Adding task 3 (2009-02-13)
        -  3.1 [ ] Adding first sub-task 3.1 (2009-02-13)
        -  3.2 [ ] Adding 2nd sub-task 3.2 (2009-02-13)
                   -  3.2.1 [ ] Adding 2nd sub-task 3.2.1 (2009-02-13)
  4 [ ] created this to move under another (4) (2009-02-13)
        -  4.1 [ ] created this to move under another (4) (2009-02-13)
  2 [@] Adding second task 2 (2009-02-13)
        -  2.1 [@] Adding first sub-task 2.1 (2009-02-13)
                   -  2.1.1 [@] Adding first sub-task 2.1.1 (2009-02-13)
                   -  2.1.2 [@] Adding 2nd sub-task 2.1.2 (2009-02-13)
                   -  2.1.3 [ ] created this to move under another (2.1.x) (2009-02-13)
                   -  2.1.4 [ ] created this to move under another (4) (2009-02-13)
                   -  2.1.5 [ ] created this to move under another (2.1.x) (2009-02-13)
        -  2.2 [ ] created this to move under another (4) (2009-02-13)

>>> todoapp.sh cu 2.1.3 4
Added 4.2 to TODO2.txt
Copied 2.1.3 to 4.2

>>> todoapp.sh --no-colors list
  1 [ ] Adding first task 1 (2009-02-13)
        -  1.1 [@] Adding first sub-task 1.1 (2009-02-13)
        -  1.2 [@] Adding 2nd sub-task 1.2 (2009-02-13)
  3 [ ] Adding task 3 (2009-02-13)
        -  3.1 [ ] Adding first sub-task 3.1 (2009-02-13)
        -  3.2 [ ] Adding 2nd sub-task 3.2 (2009-02-13)
                   -  3.2.1 [ ] Adding 2nd sub-task 3.2.1 (2009-02-13)
  4 [ ] created this to move under another (4) (2009-02-13)
        -  4.1 [ ] created this to move under another (4) (2009-02-13)
        -  4.2 [ ] created this to move under another (2.1.x) (2009-02-13)
  2 [@] Adding second task 2 (2009-02-13)
        -  2.1 [@] Adding first sub-task 2.1 (2009-02-13)
                   -  2.1.1 [@] Adding first sub-task 2.1.1 (2009-02-13)
                   -  2.1.2 [@] Adding 2nd sub-task 2.1.2 (2009-02-13)
                   -  2.1.3 [ ] created this to move under another (2.1.x) (2009-02-13)
                   -  2.1.4 [ ] created this to move under another (4) (2009-02-13)
                   -  2.1.5 [ ] created this to move under another (2.1.x) (2009-02-13)
        -  2.2 [ ] created this to move under another (4) (2009-02-13)

>>> todoapp.sh renumber 4 3
=== 1
Error: 3 already exists.

>>> todoapp.sh --no-colors list
  1 [ ] Adding first task 1 (2009-02-13)
        -  1.1 [@] Adding first sub-task 1.1 (2009-02-13)
        -  1.2 [@] Adding 2nd sub-task 1.2 (2009-02-13)
  3 [ ] Adding task 3 (2009-02-13)
        -  3.1 [ ] Adding first sub-task 3.1 (2009-02-13)
        -  3.2 [ ] Adding 2nd sub-task 3.2 (2009-02-13)
                   -  3.2.1 [ ] Adding 2nd sub-task 3.2.1 (2009-02-13)
  4 [ ] created this to move under another (4) (2009-02-13)
        -  4.1 [ ] created this to move under another (4) (2009-02-13)
        -  4.2 [ ] created this to move under another (2.1.x) (2009-02-13)
  2 [@] Adding second task 2 (2009-02-13)
        -  2.1 [@] Adding first sub-task 2.1 (2009-02-13)
                   -  2.1.1 [@] Adding first sub-task 2.1.1 (2009-02-13)
                   -  2.1.2 [@] Adding 2nd sub-task 2.1.2 (2009-02-13)
                   -  2.1.3 [ ] created this to move under another (2.1.x) (2009-02-13)
                   -  2.1.4 [ ] created this to move under another (4) (2009-02-13)
                   -  2.1.5 [ ] created this to move under another (2.1.x) (2009-02-13)
        -  2.2 [ ] created this to move under another (4) (2009-02-13)

>>> todoapp.sh --force delete 3
3: Delete successful.
Subtasks of Item 3 deleted

>>> todoapp.sh --no-colors list
  1 [ ] Adding first task 1 (2009-02-13)
        -  1.1 [@] Adding first sub-task 1.1 (2009-02-13)
        -  1.2 [@] Adding 2nd sub-task 1.2 (2009-02-13)
  4 [ ] created this to move under another (4) (2009-02-13)
        -  4.1 [ ] created this to move under another (4) (2009-02-13)
        -  4.2 [ ] created this to move under another (2.1.x) (2009-02-13)
  2 [@] Adding second task 2 (2009-02-13)
        -  2.1 [@] Adding first sub-task 2.1 (2009-02-13)
                   -  2.1.1 [@] Adding first sub-task 2.1.1 (2009-02-13)
                   -  2.1.2 [@] Adding 2nd sub-task 2.1.2 (2009-02-13)
                   -  2.1.3 [ ] created this to move under another (2.1.x) (2009-02-13)
                   -  2.1.4 [ ] created this to move under another (4) (2009-02-13)
                   -  2.1.5 [ ] created this to move under another (2.1.x) (2009-02-13)
        -  2.2 [ ] created this to move under another (4) (2009-02-13)

>>> todoapp.sh renumber 4 3
4 renumbered to 3

>>> todoapp.sh --no-colors list
  1 [ ] Adding first task 1 (2009-02-13)
        -  1.1 [@] Adding first sub-task 1.1 (2009-02-13)
        -  1.2 [@] Adding 2nd sub-task 1.2 (2009-02-13)
  3 [ ] created this to move under another (4) (2009-02-13)
        -  3.1 [ ] created this to move under another (4) (2009-02-13)
        -  3.2 [ ] created this to move under another (2.1.x) (2009-02-13)
  2 [@] Adding second task 2 (2009-02-13)
        -  2.1 [@] Adding first sub-task 2.1 (2009-02-13)
                   -  2.1.1 [@] Adding first sub-task 2.1.1 (2009-02-13)
                   -  2.1.2 [@] Adding 2nd sub-task 2.1.2 (2009-02-13)
                   -  2.1.3 [ ] created this to move under another (2.1.x) (2009-02-13)
                   -  2.1.4 [ ] created this to move under another (4) (2009-02-13)
                   -  2.1.5 [ ] created this to move under another (2.1.x) (2009-02-13)
        -  2.2 [ ] created this to move under another (4) (2009-02-13)

EOF

test_done
