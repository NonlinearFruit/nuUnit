use std assert

export def "test handles when spec does not exist" [] {
  let specFile = "not real"
  ^$nu.current-exe --no-config-file nuunit.nu --test-spec-module-name $specFile
  | assert equal $"Invalid test spec module: ($specFile)" ($in | str trim)
}

export def "test exit with error when test errors" [] {
  let specScript = "
    export module test {
      export def test_that_fails [] { exit 400 }
    }
  "
  do {
    ^nu --no-config-file nuunit.nu --test-spec-module-name "test" --test-spec-module-script $specScript
  }
  | complete
  | assert not equal 0 ($in.exit_code)
}

export def "test runs tests from spec script" [] {
  let specScript = "
    export module test {
      export def test_the_stuff [] {}
      export def test_the_other [] {}
    }
    use test *
  "
  (^$nu.current-exe --no-config-file nuunit.nu
    --test-spec-module-name "test"
    --test-spec-module-script $specScript
    --as-json)
  | from json
  | length
  | assert equal 2 $in
}