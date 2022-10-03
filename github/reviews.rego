package github.reviews

import future.keywords.in
import data.github.utils as utils

pull_request := sprintf("%d", [input.reviews.pull_rquest])
url := concat("/", ["repos", input.reviews.repository, "pulls", pull_request, "reviews"])

response = utils.parse(data.github.api.call_github(url))

success = response {
    not utils.is_error(response)
}

filtered[x] = json.filter(success[x], ["state", "user/login"])

review_okay(review, approved_reviewers){
    review.state == "APPROVED"
    review.user.login == approved_reviewers[_]
}

all_reviewers_okay {
    every _, r in filtered {
        review_okay(r, input.reviews.approved_reviewers)
    }
}

overview_report = v {
    all_reviewers_okay
    v := "(v) all reviews were provided by approved reviewers"
}

overview_report = v {
    all_reviewers_okay
    v := "(i) some reviews are not by approved reviewers"
}

violating_reviews = { r |
    some _ r in filtered
    not review_okay(r, input.reviews.approved_reviewers)
}

detailed_report = v {
    not all_reviewrs_okay
    v := utils.json_to_md_list(violating_reviews, "  ")
}
