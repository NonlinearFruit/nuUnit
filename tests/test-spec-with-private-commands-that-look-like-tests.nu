def "test private command that looks like a test is not included" [] {
  "why would you run this?"
  exit 1
}

export def "verify json results" [] {
  let results = $in
  use std assert

  assert equal 0 ($results | length)
}
