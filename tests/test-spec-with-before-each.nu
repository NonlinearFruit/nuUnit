
export def "before each" [] {
  let context = { some: stuff, that: is, useful: for, multiple: tests }
  $context
}

export def "test that before each context gets passed" [] {
  let actual = $in
  let expected = { some: stuff, that: is, useful: for, multiple: tests }
  use std assert

  assert equal $expected $actual
}

export def "test that before each context gets passed to multiple tests" [] {
  let actual = $in
  let expected = { some: stuff, that: is, useful: for, multiple: tests }
  use std assert

  assert equal $expected $actual
}

export def "verify json results" [] {
  let results = $in
  use std assert

  print ($results | get stdout)
  assert equal 0 ($results | get exit_code | first)
}

