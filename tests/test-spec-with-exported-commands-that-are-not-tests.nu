export def "not starting with test means the command will not run" [] {
  "why would you run this?"
  exit 1
}

export def "verify json results" [] {
  let results = $in
  use std assert

  assert equal 0 ($results | length)
}
