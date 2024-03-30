export def "verify json results" [] {
  let results = $in
  use std assert

  assert equal 0 ($results | length)
}
