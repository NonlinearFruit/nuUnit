#!/usr/bin/env nu

export def main [
  --test-spec-module-name = "test-spec.nu"
  --as-json
] {
  if (is-not-valid-test-spec $test_spec_module_name) {
    return $"Invalid test spec module: ($test_spec_module_name)"
  }
  let module = $test_spec_module_name | split row '/' | last | str replace '.nu' ''
  let importScript = $"use ($test_spec_module_name) *"
  let testResults = run-test-discoverer $module $importScript
  | run-tests

  $testResults
  | output-tests $as_json
  | print

  $testResults
  | get exit_code
  | sort --reverse
  | get -i 0
  | default 0
  | exit $in
}

def is-not-valid-test-spec [spec] {
  not ($spec | path exists)
}

def run-test-discoverer [module testImportScript] {
  run-nushell [
    --commands
    $"($testImportScript)
    (inline-source-code discover-tests)
    discover-tests '($module)' '($testImportScript)'
    | to nuon"
  ]
  | from nuon
}

def inline-source-code [command] {
  try {
    view source $command
  } catch {
    view source $"nuunit ($command)"
    | str replace 'nuunit ' ''
  }
}

export def discover-tests [module testImportScript] {
  scope modules
  | where name == $module
  | get commands
  | flatten
  | where name =~ '^test'
  | get name
  | enumerate
  | each {|it|
    {
      id: ($it.index + 1)
      name: $it.item
      exec: $"($testImportScript)
              try {
                if \(scope commands | where name == 'before each' | is-empty) {
                  null
                } else {
                  before each
                }
                | ($it.item)
                | if \(scope commands | where name == 'after each' | is-empty) {
                  null
                } else {
                  after each
                }
              } catch {|err|
                print -e $err.debug
                exit 1
              }"
    }
  }
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

def output-tests [asJson] {
  let tests = $in
  if ($asJson) {
    $tests | to json
  } else {
    $tests | to tap
  }
}

def "to tap" [] {
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
