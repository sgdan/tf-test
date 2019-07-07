TF=@docker-compose run --rm terraform

init:
	$(TF) init

validate:
	$(TF) validate

plan:
	$(TF) plan -out plan.bin

apply:
	$(TF) apply "plan.bin"

console:
	$(TF) console

clean:
	rm plan.bin

destroy:
	$(TF) destroy

refresh:
	$(TF) refresh

shell:
	@docker-compose run --rm --entrypoint sh terraform

fmt:
	$(TF) fmt -recursive
	$(TF) fmt -recursive ../tf-modules

list:
	$(TF) state list
