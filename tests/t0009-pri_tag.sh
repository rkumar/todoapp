#!/bin/sh
test_description="Testing out pri_tag "
. ./test-lib.sh




test_todo_session "Testing of pri_tag" <<EOF
>>> todoapp.sh add "upgrade macports"
Added 1 to TODO2.txt

>>> todoapp.sh --project ruby add "upgrade rubygems"
Added 2 to TODO2.txt

>>> todoapp.sh --project ruby --component r1.9 add "upgrade ruby 1.9"
Added 3 to TODO2.txt

>>> todoapp.sh addsub 1 "upgrade coreutils"
Added 1.1 to TODO2.txt

>>> todoapp.sh --project testing --priority D add "evaluate test frameworks"
Added 4 to TODO2.txt

>>> todoapp.sh addsub 4 "evaluate shunit"
Added 4.1 to TODO2.txt

>>> todoapp.sh addsub 4 "evaluate shunit2"
Added 4.2 to TODO2.txt

>>> todoapp.sh pri 2 A
2: priority set to A.

>>> todoapp.sh list
[1;33m  2 [ ] (A) +ruby upgrade rubygems (2009-02-13)[0m
[0;32m  4 [ ] (D) +testing evaluate test frameworks (2009-02-13)[0m
        -  4.1 [ ] evaluate shunit (2009-02-13)
        -  4.2 [ ] evaluate shunit2 (2009-02-13)
  3 [ ] +ruby @r1.9 upgrade ruby 1.9 (2009-02-13)
  1 [ ] upgrade macports (2009-02-13)
        -  1.1 [ ] upgrade coreutils (2009-02-13)

>>> todoapp.sh depri 2 A
2: priority removed.

>>> todoapp.sh list
[0;32m  4 [ ] (D) +testing evaluate test frameworks (2009-02-13)[0m
        -  4.1 [ ] evaluate shunit (2009-02-13)
        -  4.2 [ ] evaluate shunit2 (2009-02-13)
  3 [ ] +ruby @r1.9 upgrade ruby 1.9 (2009-02-13)
  2 [ ] +ruby upgrade rubygems (2009-02-13)
  1 [ ] upgrade macports (2009-02-13)
        -  1.1 [ ] upgrade coreutils (2009-02-13)

>>> todoapp.sh depri 2 A
2: no priority.

>>> todoapp.sh pri 2 B
2: priority set to B.

>>> todoapp.sh list
[1;37m  2 [ ] (B) +ruby upgrade rubygems (2009-02-13)[0m
[0;32m  4 [ ] (D) +testing evaluate test frameworks (2009-02-13)[0m
        -  4.1 [ ] evaluate shunit (2009-02-13)
        -  4.2 [ ] evaluate shunit2 (2009-02-13)
  3 [ ] +ruby @r1.9 upgrade ruby 1.9 (2009-02-13)
  1 [ ] upgrade macports (2009-02-13)
        -  1.1 [ ] upgrade coreutils (2009-02-13)

>>> todoapp.sh tag 1 URG
1: added tag URG

>>> todoapp.sh tag 1 URG
1 already tagged with URG.

>>> todoapp.sh tag 4.2 FIXME
4.2: added tag FIXME

>>> todoapp.sh list
[1;37m  2 [ ] (B) +ruby upgrade rubygems (2009-02-13)[0m
[0;32m  4 [ ] (D) +testing evaluate test frameworks (2009-02-13)[0m
        -  4.1 [ ] evaluate shunit (2009-02-13)
        -  4.2 [ ] evaluate shunit2 @FIXME (2009-02-13)
  3 [ ] +ruby @r1.9 upgrade ruby 1.9 (2009-02-13)
  1 [ ] upgrade macports @URG (2009-02-13)
        -  1.1 [ ] upgrade coreutils (2009-02-13)

EOF
test_done
