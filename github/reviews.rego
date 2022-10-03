package github.reviews

import future.keywords.in
import future.keywords.every

import data.github.utils as utils

pull_request := sprintf("%d", [input.reviews.pull_request])
url := concat("/", ["repos", input.reviews.repository, "pulls", pull_request, "reviews"])

response = utils.parse(data.github.api.call_github(url))

success = response {
  not utils.is_error(response)
}

filtered[x] = json.filter(success[x], ["state", "user/login"])

approved_reviewers := input.reviews.approved_reviewers

review_okay(review, approved_reviewers) {
  review.state == "APPROVED"
  review.user.login == approved_reviewers[_]
}

all_reviews_okay {
  every _, r in filtered {
    review_okay(r, input.reviews.approved_reviewers)
  }
}

violating_reviews = { r |
  some _, r in filtered
  not review_okay(r, input.reviews.approved_reviewers)
}

overview_report = v {
  all_reviews_okay
  v := "(v) all reviews were provided by approved reviewers"
}

overview_report = v {
  not all_reviews_okay
  v := "(i) some reviews are not by approved reviewers"
}

detailed_report = v {
  not all_reviews_okay
  v := utils.json_to_md_list(violating_reviews, "  ")
}
