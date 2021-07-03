
init:
	@$(call _checkEnv)
	./${env}/terraform.sh init ${env}

plan:
	@$(call _checkEnv)
	./${env}/terraform.sh plan ${env}

apply:
	@$(call _checkEnv)
	./${env}/terraform.sh apply ${env}

destroy:
	@$(call _checkEnv)
	./${env}/terraform.sh destroy ${env}

fmt:
	@$(call _checkEnv)
	./${env}/terraform.sh fmt ${env}

# dev, stg, prod 以外もエラーにしたい
define _checkEnv
	if [ -z ${env} ]; then\
		echo "\033[43;31mPlease specify the environment.\033[0m";\
		exit 1;\
	fi
endef