package github.report

import future.keywords.in
import data.github.utils as utils

report := [
  "# Your Gitgat Account Security Audit",
  "This report is the output of Gitgat, an experimental open source audit tool that will assist you in improving the security of your GitHub account.",
  "%s",
  "",

  "# Overview",
  "",
  "Gitgat automatically analyzes GitHub account and points to potential gaps as compared to security configuration best practices.",
  "As the project matures additional automated analyses will be added.",
  "",
  "%s",

  "# Detailed Results",
  "%s",
  "",
]

rule_set := input.rule_set { utils.exists(input, "rule_set") } else := data.rule_set

gh_overview_modules["org"] := ["repos", "tfa", "admins", "teams", "collaborators", "branches", "commits", "deploy_keys", "files", "reviews",]

gh_overview_modules["user"] := ["repos", "tfa", "admins", "teams", "collaborators", "branches", "commits", "deploy_keys", "ssh_keys", "files", "reviews",]

gh_detailed_modules["org"] := ["repos", "tfa", "admins", "teams", "collaborators", "branches", "commits", "deploy_keys", "reviews",]

gh_detailed_modules["user"] := ["repos", "tfa", "admins", "teams", "collaborators", "branches", "commits", "deploy_keys", "ssh_keys", "reviews",]

gh_intro["org"] := v {
  orgs := utils.json_to_md_list(input.organizations, "  ")
  v := sprintf("This report is an organizational report referring to the following organizations: %s", [orgs])
}

gh_intro["user"] := "This report is a user-view report, and includes all organizations that the user belongs to."

f_report := v {
  overview_reports := [data.github[m].overview_report | some m in gh_overview_modules[rule_set]]
  overview_report := concat("\n", overview_reports)

  detailed_reports := [data.github[m].detailed_report | some m in gh_detailed_modules[rule_set]]
  detailed_report := concat("\n", detailed_reports)

  c_report := concat("\n", report)
  v := sprintf(c_report, [gh_intro[rule_set], overview_report, detailed_report])
}

print_report = v {
  print(f_report)
  v := 1
}

gh_update_modules["user"] := ["token", "admins", "tfa"]

f_update := v {
  v := { m: data.github[m].update | some m in gh_update_modules[rule_set] }
}

print_update = v {
  print(f_update)
  v := 1
}
