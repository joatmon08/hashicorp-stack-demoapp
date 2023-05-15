package terraform.policies.configuration

import input.plan as plan

resource_changes := plan.resource_changes

deny[msg] {
	resources_missing_tags := { resource_changes[r].address | tags := resource_changes[r].change.after.tags
                                                              not tags.Environment }
    resources_still_missing_tags := { resource_changes[r].address | tags := resource_changes[r].change.after.tags_all
                                                                    not tags.Environment }

    resources_need_tags := resources_missing_tags & resources_still_missing_tags

    count(resources_need_tags) != 0
	msg := sprintf("%v resources should have Environment tag", [resources_need_tags])
}

deny[msg] {
	resources_missing_tags := { resource_changes[r].address | tags := resource_changes[r].change.after.tags
                                                              not tags.Automation }
    resources_still_missing_tags := { resource_changes[r].address | tags := resource_changes[r].change.after.tags_all
                                                                    not tags.Automation }

    resources_need_tags := resources_missing_tags & resources_still_missing_tags

    count(resources_need_tags) != 0
	msg := sprintf("%v resources should have Automation tag", [resources_need_tags])
}