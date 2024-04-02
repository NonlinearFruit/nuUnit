export def "test 1" [] {}
export def "test 2" [] {}
export def "test 3" [] {}
export def "test 4" [] {}
export def "test 5" [] {}

export def "verify json results" [] {
  let results = $in | from json
  print $results
  use std assert

  assert equal 5 ($results | length)
}
