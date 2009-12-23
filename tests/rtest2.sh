#!/bin/bash
#*******************************************************#
#                       gentest.sh                      #
#                 written by Rahul Kumar                #
#                    December 21, 2009                  #
#                                                       #
#                  generates a test case                #
#*******************************************************#
# @param - test descriptor - short name
#+ will be used in test_desc and filename suffix
#
# If testing for error, and command returns 1
#+ place "=== 1" on first line or result

while [[ $1 = -* ]]; do
case "$1" in                    
   -L|--load)
   # load a file containing TODO2.txt data to test against
      dataset=../$2
      shift
      shift
      ;;
   *)
      echo "Error: Unknown option: $1" >&2   # rem _
      exit 1
      ;;
esac
done

if [[ -z "$1" ]]; then
   echo -n "Test Description (short, no spaces): " 1>&2
   read td
else
   td="$1"
fi
# for generating a serial number
APP="todoapp-test"

PS1=">>>"
out="$(pwd)/transcript.txt"
test_description="Testing of $td"
filesuffix=$( echo "$td" | sed 's/ /_/g' )


. ./test-lib.sh
trap - EXIT
if [[ ! -z "$dataset" ]]; then
   if [[ ! -f "$dataset" ]]; then
      echo "Can't find file $dataset"
      exit 1
   else
      wc -l "$dataset"
   fi
fi
if [[ ! -z "$dataset" ]]; then
   cp "${dataset}" TODO2.txt
   pre+=$( echo -e "cat > TODO2.txt <<CATEOF")
   pre+="\n"
   pre+=$(cat TODO2.txt)
   pre+=$( echo -e "\nCATEOF\n" )
fi
str=""
> "$out"

## get user input, stop when user enters 'bye'
while read line
do
#   echo -n ">>> "
#   read line
   [ -z "$line" ] && { echo "bye to quit"; continue; }
   [[ "$line" = "bye" ]] && break;

   ## user can execute test_tick in current shell
   [[ "$line" = *test_tick* ]] && {
      times=$( expr "$line" : 'test_tick \(.*\)' )
      # should be multiples of 86400 or at least more than 86400
      test_tick $times;
   }

   [[ "$line" = "ls" || "$line" = "list" ]] && line="t --sort-serial list";
   line=$(echo "$line" | sed 's/^t /todoapp.sh /')
   echo ">>> $line" >> $out
   eval "$line" | tee -a "$out"
   echo "" >> $out
done

## generate the test case transcript
str="$( cat $out )"
> "$out"
cat > "$out" <<EOF
#!/bin/sh
test_description="Testing out $td "
. ./test-lib.sh


EOF
echo -e "$pre" >> "$out"
echo "" >> "$out"
echo "test_todo_session \"Testing of $td\" <<EOF" >> "$out"
echo "$str" >> "$out"
echo "" >> "$out"
echo "EOF" >> "$out"
echo "test_done" >> "$out"

# try to create a decent file name
serno=$( get_serial_number -a "$APP" -d "../"  )
serno=$( printf "%04s" "$serno" )
filename="../t${serno}-${filesuffix}.sh"
cp -i "$out" "$filename"
chmod +x "$filename"
echo "Please rename $filename to prevent possible overwriting"
