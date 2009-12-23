#!/bin/sh
test_description="Testing out last_opt "
. ./test-lib.sh




test_todo_session "Testing of last_opt" <<EOF
>>> todoapp.sh add checking last task option
Added 1 to TODO2.txt

>>> todoapp.sh add add another task
Added 2 to TODO2.txt

>>> todoapp.sh addsub last okay this should get added under 2
Added 2.1 to TODO2.txt

>>> todoapp.sh add gotta get a life really
Added 3 to TODO2.txt

>>> todoapp.sh addsub last what sorta life do you propose
Added 3.1 to TODO2.txt

>>> todoapp.sh --recursive mark last start
3: Marked as start
Subtasks of Item 3 marked as start

>>> todoapp.sh --recursive mark last close
3: Marked as close
Subtasks of Item 3 marked as close

>>> todoapp.sh --no-colors list
  2 [ ] add another task (2009-02-13)
        -  2.1 [ ] okay this should get added under 2 (2009-02-13)
  1 [ ] checking last task option (2009-02-13)
  3 [x] gotta get a life really (2009-02-13) (x2009-02-13)
        -  3.1 [x] what sorta life do you propose (2009-02-13) (x2009-02-13)

>>> todoapp.sh --force delete last
3: Delete successful.
Subtasks of Item 3 deleted

>>> todoapp.sh --no-colors list
  2 [ ] add another task (2009-02-13)
        -  2.1 [ ] okay this should get added under 2 (2009-02-13)
  1 [ ] checking last task option (2009-02-13)

EOF
test_done
