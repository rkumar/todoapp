#!/bin/sh
test_description="Testing out defaultaction "
. ./test-lib.sh


cat > TODO2.txt <<CATEOF
  1	[ ] +ruby Adding first task 1 (2009-02-13)
        -  1.1	[ ] +ruby Adding first sub-task 1.1 (2009-02-13)
        -  1.2	[ ] +ruby Adding 2nd sub-task 1.2 (2009-02-13)
  2	[ ] Adding second task 2 (2009-02-13)
        -  2.1	[ ] +sql Adding first sub-task 2.1 (2009-02-13)
                   -  2.1.1	[ ] Adding first sub-task 2.1.1 (2009-02-13)
                   -  2.1.2	[ ] Adding 2nd sub-task 2.1.2 (2009-02-13)
  3	[ ] +sql Adding task 3 (2009-02-13)
        -  3.1	[ ] Adding first sub-task 3.1 (2009-02-13)
        -  3.2	[ ] Adding 2nd sub-task 3.2 (2009-02-13)
                   -  3.2.1	[ ] Adding 2nd sub-task 3.2.1 (2009-02-13)
CATEOF

test_todo_session "Testing of defaultaction" <<EOF
>>> todoapp.sh
  1 [ ] +ruby Adding first task 1 (2009-02-13)
        -  1.1 [ ] +ruby Adding first sub-task 1.1 (2009-02-13)
        -  1.2 [ ] +ruby Adding 2nd sub-task 1.2 (2009-02-13)
  3 [ ] +sql Adding task 3 (2009-02-13)
        -  3.1 [ ] Adding first sub-task 3.1 (2009-02-13)
        -  3.2 [ ] Adding 2nd sub-task 3.2 (2009-02-13)
                   -  3.2.1 [ ] Adding 2nd sub-task 3.2.1 (2009-02-13)
  2 [ ] Adding second task 2 (2009-02-13)
        -  2.1 [ ] +sql Adding first sub-task 2.1 (2009-02-13)
                   -  2.1.1 [ ] Adding first sub-task 2.1.1 (2009-02-13)
                   -  2.1.2 [ ] Adding 2nd sub-task 2.1.2 (2009-02-13)

EOF
test_done
