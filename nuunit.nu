def main [--test-spec-module-name = "test-spec.nu"] {
  if (not ($test_spec_module_name | path exists)) {
    return $"Invalid test spec module: ($test_spec_module_name)"
  }
  discover-tests $test_spec_module_name
  | run-tests
  | output-tests
}

def discover-tests [testSpecModuleName] {
  let module = $testSpecModuleName | str replace '.nu' ''
  run-nushell [
      --commands
      $"use ($testSpecModuleName)

      scope modules
      | where name == '($module)'
      | get commands
      | flatten
      | where name =~ '^test'
      | get name
      | enumerate
      | each {|it|
        {
          id: \($it.index + 1)
          name: $it.item
          exec: $'use ($testSpecModuleName) *; try {\($it.item)} catch {|err| print -e $err.debug; exit 1}'
        }
      }
      | to nuon"
  ]
  | from nuon
}

def run-tests [] {
  $in
  | par-each {|test|
    do {
        run-nushell [
            --commands
            $test.exec
        ]
    }
    | complete
    | insert id $test.id
    | insert name $test.name
  }
}

def output-tests [] {
  $in
  | each {|testResult|
    if $testResult.exit_code == 0 {
      $"ok ($testResult.id) - ($testResult.name)"
    } else {
      $testResult
      | select stdout stderr exit_code
      | to yaml
      | lines
      | each {"  " ++ $in}
      | [
        $"not ok ($testResult.id) - ($testResult.name)"
        "  ---"
        ...$in
        "  ..."
      ]
      | str join (char newline)
    }
  }
  | [
    "TAP version 14"
    $"1..($in | length)"
    ...$in
  ]
  | str join (char newline)
}

def run-nushell [params: list] {
  ^$nu.current-exe --no-config-file ...$params
}
