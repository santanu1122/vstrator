#!/bin/sh

remove_prefix_and_print()
{
  echo $1 | sed -E 's/^\.\.\/\.\.\/(VstratorApp|VstratorCore)\///'
}

# Populate image files. Skip *.HQ/ files and @2x files
find ../../VstratorApp/Resources/Design -name *jpg -type f | grep -v \.HQ\/ | grep -v @2x >list.txt
find ../../VstratorApp/Resources/Design -name *png -type f | grep -v \.HQ\/ | grep -v @2x >>list.txt

# Populate sources
find ../../VstratorApp/ -name "*.xib" >list2.txt
find ../../VstratorApp/ -name "*.m" >>list2.txt
find ../../VstratorApp/ -name "*.h" >>list2.txt
find ../../VstratorApp/ -name "*.xib" >>list2.txt
find ../../VstratorApp/ -name "*.m" >>list2.txt
find ../../VstratorApp/ -name "*.h" >>list2.txt

# Check every image
while read IMAGE_FILE; do
  # Extract filename w/o extension
  filename=$(basename $IMAGE_FILE)
  filename="${filename%.*}"

  remove_prefix_and_print "$IMAGE_FILE:"

  # Check every source file
  while read SOURCE_FILE; do
    grep $filename -h -o $SOURCE_FILE >/dev/null
    if [ $? -eq 0 ]; then
      printf "\t"
      remove_prefix_and_print $SOURCE_FILE
    fi
  done<list2.txt
done <list.txt

# Cleanup
rm list.txt
rm list2.txt


