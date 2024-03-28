use std assert

export def "test handles when spec does not exist" [] {
  let specFile = "not real"
  ^$nu.current-exe --no-config-file nuunit.nu --test-spec-module-name $specFile
  | assert equal $"Invalid test spec module: ($specFile)" ($in | str trim)
}
