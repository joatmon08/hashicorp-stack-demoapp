package terraform.policies.communication

import input.plan as plan

planned_values := plan.planned_values
resource_changes := plan.resource_changes

deny[msg] {
	r := resource_changes[_]
	r.type == "aws_eks_cluster"
	cluster_id := r.change.after.id

	subnet_ids := cast_set(r.change.after.vpc_config[_].subnet_ids)

	vpc_modules := [module |
		module := planned_values.root_module.child_modules[_]
		module.address == "module.vpc"
	]

	private_subnets := {r.values.id |
		r := vpc_modules[_].resources[_]
		r.type == "aws_subnet"
		not r.values.map_public_ip_on_launch
	}

	public_subnets := subnet_ids - private_subnets

	count(public_subnets) != 0
	msg := sprintf("EKS cluster %v should be in private subnets (%v are public subnets)", [cluster_id, public_subnets])
}
