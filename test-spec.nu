use std assert

export def "test handles when spec does not exist" [] {
  let specFile = "not real"
  ^$nu.current-exe --no-config-file nuunit.nu --test-spec-module-name $specFile
  | assert equal $"Invalid test spec module: ($specFile)" ($in | str trim)
}

export def "test exit with error when test errors" [] {
  use tests/test-spec-that-errs.nu "verify json results"
  let specFile = "tests/test-spec-that-errs.nu"

  do {
    ^$nu.current-exe --no-config-file nuunit.nu --test-spec-module-name $specFile
  }
  | complete
  | assert not equal 0 ($in.exit_code)
}

export def "test when there are no tests everything still works" [] {
  use tests/test-spec-with-zero-tests.nu "verify json results"
  let specFile = "tests/test-spec-with-zero-tests.nu"

  run-test-spec $specFile
  | verify json results
}

export def "test when there is one test everything still works" [] {
  use tests/test-spec-with-one-test.nu "verify json results"
  let specFile = "tests/test-spec-with-one-test.nu"

  run-test-spec $specFile
  | verify json results
}

export def "test when there are two tests everything still works" [] {
  use tests/test-spec-with-two-tests.nu "verify json results"
  let specFile = "tests/test-spec-with-two-tests.nu"

  run-test-spec $specFile
  | verify json results
}

export def "test when test errors runner keeps chugging" [] {
  use tests/test-spec-that-errs.nu "verify json results"
  let specFile = "tests/test-spec-that-errs.nu"

  run-test-spec $specFile
  | verify json results
}

export def "test when exported command does not match pattern it is not included" [] {
  use tests/test-spec-with-exported-commands-that-are-not-tests.nu "verify json results"
  let specFile = "tests/test-spec-with-exported-commands-that-are-not-tests.nu"

  run-test-spec $specFile
  | verify json results
}

export def "test private commands that look likes tests are not included" [] {
  use tests/test-spec-with-private-commands-that-look-like-tests.nu "verify json results"
  let specFile = "tests/test-spec-with-private-commands-that-look-like-tests.nu"

  run-test-spec $specFile
  | verify json results
}

export def "test output is tap compliant" [] {
  use tests/test-spec-outputs-tap.nu "verify tap results"
  let specFile = "tests/test-spec-outputs-tap.nu"

  ^$nu.current-exe --no-config-file nuunit.nu --test-spec-module-name $specFile
  | verify tap results
}

export def "test can run via nu cli" [] {
  use tests/generic-test-spec.nu "verify json results"
  let specFile = "tests/generic-test-spec.nu"

  (^$nu.current-exe --no-config-file nuunit.nu --test-spec-module-name $specFile --as-json)
  | verify json results
}

export def "test can run via nu script" [] {
  use tests/generic-test-spec.nu "verify json results"
  let specFile = "tests/generic-test-spec.nu"
  let script = $"use nuunit.nu *; nuunit --test-spec-module-name ($specFile) --as-json"

  ^$nu.current-exe --no-config-file -c $script
  | verify json results
}

export def "test can run via shebang" [] {
  use tests/generic-test-spec.nu "verify json results"
  let specFile = "tests/generic-test-spec.nu"

  ^./nuunit.nu  --test-spec-module-name ($specFile) --as-json
  | verify json results
}

export def "test that the before each passes context to a test" [] {
  use tests/test-spec-with-before-each.nu "verify json results"
  let specFile = "tests/test-spec-with-before-each.nu"

  run-test-spec $specFile
  | verify json results
}

def run-test-spec [specFile] {
  (^$nu.current-exe --no-config-file nuunit.nu --test-spec-module-name $specFile --as-json)
  | from json
}
