#! /bin/bash

array=("one" "two" "potatoes" "bananas" "three" "apples")
value="\<${1}\>" #the value variable is assigned a regex that matches the exact value of the first argument 

if [[ ${array[@]} =~ $value ]]
then
  echo "value found"
else
  echo "value not found"
fi

fruits="${array[@]}"
compgen -W "$fruits" "t"
compgen -W "${array[*]}" "t"
