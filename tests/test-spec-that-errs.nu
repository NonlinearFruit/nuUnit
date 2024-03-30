export def "test that is broken" [] {
  error make { msg: "It broke!" }
}

export def "verify json results" [] {
  let results = $in
  use std assert

  assert equal 1 ($results | length)
  assert not equal 0 ($results.exit_code)
  assert not equal "" ($results.stderr)
}
