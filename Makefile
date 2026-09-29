.PHONY: fmt fmt-check validate test lint validate-task-1 validate-task-2 validate-task-3 validate-task-4 validate-task-5 test-task-1 test-task-2 test-task-3 test-task-4 test-task-5

fmt:
	terraform fmt -recursive

fmt-check:
	terraform fmt -check -recursive

validate: validate-task-1 validate-task-2 validate-task-3 validate-task-4 validate-task-5

test: test-task-1 test-task-2 test-task-3 test-task-4 test-task-5

validate-task-1:
	terraform -chdir=task-01-ec2-fleet init -backend=false
	terraform -chdir=task-01-ec2-fleet validate

validate-task-2:
	terraform -chdir=task-02-remote-state/bootstrap init -backend=false
	terraform -chdir=task-02-remote-state/bootstrap validate

validate-task-3:
	terraform -chdir=task-03-cross-account-iam init -backend=false
	terraform -chdir=task-03-cross-account-iam validate

validate-task-4:
	terraform -chdir=task-04-ci-least-privilege init -backend=false
	terraform -chdir=task-04-ci-least-privilege validate

validate-task-5:
	terraform -chdir=task-05-bug-fix init -backend=false
	terraform -chdir=task-05-bug-fix validate

test-task-1:
	terraform -chdir=task-01-ec2-fleet test

test-task-2:
	terraform -chdir=task-02-remote-state/bootstrap test

test-task-3:
	terraform -chdir=task-03-cross-account-iam test

test-task-4:
	terraform -chdir=task-04-ci-least-privilege test

test-task-5:
	terraform -chdir=task-05-bug-fix test

lint:
	tflint --recursive
