#!/bin/sh

IMAGE_FILE=$1

remove_prefix_and_print()
{
  echo $1 | sed -E 's/^\.\.\/\.\.\/(VstratorApp|VstratorCore)\///'
}

# Populate sources
find ../../VstratorApp/ -name "*.xib" >list2.txt
find ../../VstratorApp/ -name "*.m" >>list2.txt
find ../../VstratorApp/ -name "*.h" >>list2.txt
find ../../VstratorCore/ -name "*.xib" >>list2.txt
find ../../VstratorCore/ -name "*.m" >>list2.txt
find ../../VstratorCore/ -name "*.h" >>list2.txt

# Check every image
#while read IMAGE_FILE; do
  # Extract filename w/o extension
  filename=$(basename $IMAGE_FILE)
  filename="${filename%.*}"

  n=0
  remove_prefix_and_print "$IMAGE_FILE:"

  # Check every source file
  while read SOURCE_FILE; do
    grep $filename -h -o $SOURCE_FILE >/dev/null
    if [ $? -eq 0 ]; then
      printf "\t"
      remove_prefix_and_print $SOURCE_FILE
      ((n++))
#      break;
    fi
  done<list2.txt

#  if [ $n -eq 0 ]; then
#    remove_prefix_and_print $IMAGE_FILE
#  fi

#done <"$1/list.txt"

# Cleanup
#rm list.txt
rm list2.txt


