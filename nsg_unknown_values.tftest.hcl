mock_provider "azurerm" {}

run "rules_with_unknown_values_have_known_keys" {
  command = plan

  providers = {
    azurerm = azurerm
  }

  module {
    source = "./tests/fixtures/unknown_rule_values"
  }

  assert {
    condition     = toset(output.rule_keys) == toset(["shared_https", "sub_a_https"])
    error_message = "rule keys must be known at plan time even when rule values are not"
  }
}
