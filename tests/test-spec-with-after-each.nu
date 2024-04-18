
export def "test that after each gets context from test" [] {
  let context = { some: stuff, that: is, useful: for, multiple: tests }
  $context
}

export def "test that after each context gets passed to multiple tests" [] {
  let context = { some: stuff, that: is, useful: for, multiple: tests }
  $context
}

export def "after each" [] {
  let actual = $in
  let expected = { some: stuff, that: is, useful: for, multiple: tests }
  use std assert

  print "after each happened"

  assert equal $expected $actual
}

export def "verify json results" [] {
  let results = $in
  use std assert

  assert ($results | get exit_code | all {|it| $it == 0})
  assert ($results | get stdout | all {|it| $it =~ "after each happened"})
}

