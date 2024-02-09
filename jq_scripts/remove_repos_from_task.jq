#!/usr/bin/jq --from-file

. + {
  "repos": [
     try .repos[]
     | . as $repo
     | $ARGS.positional
     | select(index($repo) == null)
     | $repo
  ]
}
