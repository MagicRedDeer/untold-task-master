#!/usr/bin/jq --from-file

# Getting all the task_files and task_names
# assuming that they have been passed in as named args
# i.e. name=path and value=content
$ARGS.named
| keys[]
| select(.!="status")
| . as $task_file
| split("/")[-2] as $task_name  # extracting task_name

# filtering out invalid jsons by compiling and checking name
| $ARGS.named[$task_file]
| try fromjson
| select(.name==$task_name)

# selecting all tasks with required status (if required)
| if $ARGS.named.status != null then
    # task filter by status
    select(.status==$ARGS.named.status)
  else
    .
  end

# and returning their names
| $task_name
