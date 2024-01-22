#!/usr/bin/jq --from-file

# Getting all the task_files and task_names
$ARGS.named
| keys
| .[]
| select(.!="status")
| . as $task_file
| split("/")[-2] as $task_name  # extracting task_name

# filtering out invalid jsons
| $ARGS.named[$task_file]
| try fromjson catch empty
| select(.name==$task_name)

# selecting and returning the required task
| if $ARGS.named.status != null then
    select(.status==$ARGS.named.status)
  else
    .
  end
| $task_name
