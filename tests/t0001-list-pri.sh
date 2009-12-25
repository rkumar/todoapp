#!/bin/sh
test_description="Testing out list-pri "
. ./test-lib.sh


cat > TODO2.txt <<CATEOF
  1	[ ] (B) +ta @list. option @IMP @URG (2009-12-17)
       -  1.1	[ ] (B) +ta @list. give --depth option @IMP (2009-12-17)
       -  1.2	[ ] (B) +ta @list. give --hide-subtasks option (2009-12-17)
       -  1.3	[x] (A) +ta @list. give --hide-completed option (2009-12-22) (x2009-12-22)
       -  1.4	[ ] search on project, use --project option in @list (2009-12-23)
       -  1.5	[ ] grep option, or search on terms $1... (2009-12-23)
  2	[x] (D) +ta @list coloring. red=paused, blue=fin, green=wip, white-unstarted (2009-12-14) (x2009-12-21)
  5	[ ] +rbc @ui testing out some item 4
     -  5.1	[x] Adding a subtask under 5... (2009-12-17) (x2009-12-19)
          -  5.1.1	[H] Adding a subtask under 5... (2009-12-17) (x2009-12-19)
     -  5.2	[ ] Adding a subtask under 5... (2009-12-17)
  7	[@] +rbc @splitp handle_keys to be done (2009-12-14)
 11	[x] +ta tagging of tasks (2009-12-17) (x2009-12-19)
        -  11.1	[x] Where to place tags (2009-12-18) (x2009-12-19)
 13	[ ] (C) +ta configure so one global file if user wants (2009-12-17)
 14	[ ] (D) +ta option for changing start date (2009-12-17)
 15	[ ] (E) +ta option for changing project or component (2009-12-17)
 16	[H] (E) +ta option for changing text (2009-12-17)
 17	[x] +ta Numbering issues (2009-12-18) (x2009-12-19)
        -  17.1	[x] after a while numbering becomes to high (2009-12-18) (x2009-12-19)
        -  17.2	[x] option to renumber all from 1 (2009-12-18) (x2009-12-19)
 27	[x] +ta addsub should have option to add under last item (2009-12-21) (x2009-12-21)
        -  27.1	[x] trying to add below last (2009-12-21) (x2009-12-21)
        -  27.2	[x] trying to add below last again (2009-12-21) (x2009-12-21)
 28	[x] +ta mark: make statuses friendlier (2009-12-22) (x2009-12-22)
 29	[x] +ta an empty line hangs list action (2009-12-22) (x2009-12-22)
CATEOF

test_todo_session "Testing of list-pri" <<EOF
>>> todoapp.sh --no-colors --priority B list
  1 [ ] (B) +ta @list. option @IMP @URG (2009-12-17)
       -  1.1 [ ] (B) +ta @list. give --depth option @IMP (2009-12-17)
       -  1.2 [ ] (B) +ta @list. give --hide-subtasks option (2009-12-17)

>>> todoapp.sh --no-colors --priority AB list
  1 [ ] (B) +ta @list. option @IMP @URG (2009-12-17)
       -  1.1 [ ] (B) +ta @list. give --depth option @IMP (2009-12-17)
       -  1.2 [ ] (B) +ta @list. give --hide-subtasks option (2009-12-17)
       -  1.3 [x] (A) +ta @list. give --hide-completed option (2009-12-22) (x2009-12-22)

>>> todoapp.sh --no-colors --priority any list
  1 [ ] (B) +ta @list. option @IMP @URG (2009-12-17)
       -  1.1 [ ] (B) +ta @list. give --depth option @IMP (2009-12-17)
       -  1.2 [ ] (B) +ta @list. give --hide-subtasks option (2009-12-17)
       -  1.3 [x] (A) +ta @list. give --hide-completed option (2009-12-22) (x2009-12-22)
 13 [ ] (C) +ta configure so one global file if user wants (2009-12-17)
 14 [ ] (D) +ta option for changing start date (2009-12-17)
 15 [ ] (E) +ta option for changing project or component (2009-12-17)
 16 [H] (E) +ta option for changing text (2009-12-17)
  2 [x] (D) +ta @list coloring. red=paused, blue=fin, green=wip, white-unstarted (2009-12-14) (x2009-12-21)

>>> todoapp.sh --no-colors --priority ^B list
 13 [ ] (C) +ta configure so one global file if user wants (2009-12-17)
 14 [ ] (D) +ta option for changing start date (2009-12-17)
 15 [ ] (E) +ta option for changing project or component (2009-12-17)
 16 [H] (E) +ta option for changing text (2009-12-17)
       -  1.3 [x] (A) +ta @list. give --hide-completed option (2009-12-22) (x2009-12-22)
  2 [x] (D) +ta @list coloring. red=paused, blue=fin, green=wip, white-unstarted (2009-12-14) (x2009-12-21)

EOF
test_done
