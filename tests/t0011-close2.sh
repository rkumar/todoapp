#!/bin/sh
test_description="Testing out close2 "
. ./test-lib.sh


cat > TODO2.txt <<CATEOF
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
CATEOF

test_todo_session "Testing of close2" <<EOF
>>> todoapp.sh --recursive mark 3.2 close
3.2: Marked as close
Subtasks of Item 3.2 marked as close

>>> todoapp.sh list
  1 [ ] Adding first task 1 (2009-02-13)
        -  1.1 [@] Adding first sub-task 1.1 (2009-02-13)
        -  1.2 [@] Adding 2nd sub-task 1.2 (2009-02-13)
  3 [ ] Adding task 3 (2009-02-13)
        -  3.1 [ ] Adding first sub-task 3.1 (2009-02-13)
        -  3.2 [0;31m[x][0m Adding 2nd sub-task 3.2 (2009-02-13) (x2009-02-13)
                   -  3.2.1 [0;31m[x][0m Adding 2nd sub-task 3.2.1 (2009-02-13) (x2009-02-13)
  2 [@] Adding second task 2 (2009-02-13)
        -  2.1 [@] Adding first sub-task 2.1 (2009-02-13)
                   -  2.1.1 [@] Adding first sub-task 2.1.1 (2009-02-13)
                   -  2.1.2 [@] Adding 2nd sub-task 2.1.2 (2009-02-13)

>>> todoapp.sh --recursive  mark 3 close
3: Marked as close
Subtasks of Item 3 marked as close

>>> todoapp.sh list
  1 [ ] Adding first task 1 (2009-02-13)
        -  1.1 [@] Adding first sub-task 1.1 (2009-02-13)
        -  1.2 [@] Adding 2nd sub-task 1.2 (2009-02-13)
  2 [@] Adding second task 2 (2009-02-13)
        -  2.1 [@] Adding first sub-task 2.1 (2009-02-13)
                   -  2.1.1 [@] Adding first sub-task 2.1.1 (2009-02-13)
                   -  2.1.2 [@] Adding 2nd sub-task 2.1.2 (2009-02-13)
  3 [0;31m[x][0m Adding task 3 (2009-02-13) (x2009-02-13)
        -  3.1 [0;31m[x][0m Adding first sub-task 3.1 (2009-02-13) (x2009-02-13)
        -  3.2 [0;31m[x][0m Adding 2nd sub-task 3.2 (2009-02-13) (x2009-02-13)
                   -  3.2.1 [0;31m[x][0m Adding 2nd sub-task 3.2.1 (2009-02-13) (x2009-02-13)

>>> todoapp.sh --force delete 3.2
3.2: Delete successful.
Subtasks of Item 3.2 deleted

>>> todoapp.sh list
  1 [ ] Adding first task 1 (2009-02-13)
        -  1.1 [@] Adding first sub-task 1.1 (2009-02-13)
        -  1.2 [@] Adding 2nd sub-task 1.2 (2009-02-13)
  2 [@] Adding second task 2 (2009-02-13)
        -  2.1 [@] Adding first sub-task 2.1 (2009-02-13)
                   -  2.1.1 [@] Adding first sub-task 2.1.1 (2009-02-13)
                   -  2.1.2 [@] Adding 2nd sub-task 2.1.2 (2009-02-13)
  3 [0;31m[x][0m Adding task 3 (2009-02-13) (x2009-02-13)
        -  3.1 [0;31m[x][0m Adding first sub-task 3.1 (2009-02-13) (x2009-02-13)

>>> todoapp.sh --force delete 3
3: Delete successful.
Subtasks of Item 3 deleted

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
