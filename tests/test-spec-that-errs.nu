export def "test that is broken" [] {
  error make { msg: "It broke!" }
}

export def "test after broken test that is fine" [] {
  "Bug where nuunit only exits with
   error when the _last_ test errs.
   This test passes after the failure
   above to make sure nuunit err when
   any test errs"
}

export def "verify json results" [] {
  let results = $in
  use std assert

  assert equal 2 ($results | length)
  assert not equal 0 ($results.exit_code)
  assert not equal "" ($results.stderr)
}
