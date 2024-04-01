export def "test 1" [] {}
export def "test 2" [] {}

export def "verify tap results" [] {
  let results = $in
  use std assert
  let tap = "TAP version 14
1..2
ok 1 - test 1
ok 2 - test 2
"
  assert equal $tap $results
}

