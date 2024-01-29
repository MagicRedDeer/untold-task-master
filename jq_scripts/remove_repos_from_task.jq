#!/usr/bin/jq --from-file

# save main dict to alias

. + {
  "repos": [
     try .repos[]
     | . as $repo
     | $ARGS.positional
     | select(index($repo) == null)
     | $repo
  ]
}
