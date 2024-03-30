export def "test 1" [] {}
export def "test 2" [] {}

export def "verify json results" [] {
  let results = $in
  use std assert

  assert equal 2 ($results | length)
}

