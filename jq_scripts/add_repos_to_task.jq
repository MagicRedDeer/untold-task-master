#!/usr/bin/jq --from-file

# save main dict to alias
. as $orig

# build complete list of repos
| if ($orig.repos != null) then
    $orig.repos + $ARGS.positional
  else
    $ARGS.positional
  end
| unique as $repos

# assign to main dict and return
| $orig
| . += {
    "repos": $repos,
  }
