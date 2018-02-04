# Linter config overrides
use Mix.Config

config :dogma,
  rule_set: Dogma.RuleSet.All,
  override: [
    %Dogma.Rule.LineLength{ max_length: 120 }
  ]
