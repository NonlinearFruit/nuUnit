export def "test 1" [] {}

export def "verify json results" [] {
  let results = $in
  use std assert

  assert equal 1 ($results | length)
}

