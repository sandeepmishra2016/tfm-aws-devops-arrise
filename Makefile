.PHONY: fmt validate

TASKS := \
	task-01-ec2-fleet \
	task-02-remote-state/bootstrap \
	task-03-cross-account-iam \
	task-04-ci-least-privilege \
	task-05-bug-fix

fmt:
	terraform fmt -recursive

validate:
	@for task in $(TASKS); do \
		echo "Validating $$task"; \
		terraform -chdir=$$task init -backend=false -input=false >/dev/null; \
		terraform -chdir=$$task validate || exit 1; \
	done
