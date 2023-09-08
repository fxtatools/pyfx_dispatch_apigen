## GNU Makefile for PyFX::Dispatch::APIGen

BUILDDIR?=			build
SCRIPTSDIR?=			${BUILDDIR}/scripts

OPENAPI_GENERATOR_SH?=		openapi-generator-cli.sh
OPENAPI_GENERATOR_ORIGIN?=	https://raw.githubusercontent.com/OpenAPITools/openapi-generator/master/bin/utils/${OPENAPI_GENERATOR_SH}

PYTHON?=			python3
PYVENV_DIR?=			env
REQUIREMENTS_IN?=		requirements.in
REQUIREMENTS_TXT?=		requirements.txt
PYVENV_DEPS?=			${PYVENV_DIR}/pyvenv.cfg
PROJECT_PY?=			project.py
FETCH?=				${PYTHON} ${PROJECT_PY} fetch
FETCH_DEPS?=			${PROJECT_PY}

all:

fetch: ${SCRIPTSDIR}/${OPENAPI_GENERATOR_SH}

env: ${PYVENV_DIR}/pyvenv.cfg

${PYVENV_DIR}/pyvenv.cfg:
	if ! [ -d "${PYVENV_DIR}" ]; then ${PYTHON} ${PROJECT_PY} ensure_env ${PYVENV_DIR}; fi

${REQUIREMENTS_TXT}:		${REQUIREMENTS_IN}

${SCRIPTSDIR}/${OPENAPI_GENERATOR_SH}: ${FETCH_DEPS}
	mkdir -p ${SCRIPTSDIR}
	if ! [ -e "$@" ]; then ${FETCH} ${OPENAPI_GENERATOR_ORIGIN} "$@"; fi
	chmod +x "$@"

realclean:
	rm -fv ${SCRIPTSDIR}/${OPENAPI_GENERATOR_SH}

# api:
## e.g for client gen (sort of)
##  HERE=$PWD; mkdir -p ${HERE}/api/client; cd ${HERE}/api/client; ${HERE}/scripts/openapi-generator-cli.sh generate -g python --additional-properties library=asyncio --additional-properties disallowAdditionalPropertiesIfNotPresent=false --additional-properties packageName=pyfx.dispatch.oanda.api --additional-properties packageVersion=1.0.0 --additional-properties projectName=pyfx_dispatch_oanda_api   -i ${HERE}/build/v20-openapi-3.0.25/json/v20.json --invoker-package pyfx.dispatch.oanda.api --skip-validate-spec
## e.g for server gen
## HERE=$PWD; mkdir -p build/api/oanda; cd build/api/oanda; ${HERE}/scripts/openapi-generator-cli.sh generate -g python-aiohttp --additional-properties controllerPackage=controllers --additional-properties  disallowAdditionalPropertiesIfNotPresent=false --additional-properties  enumUnknownDefaultCase=true --additional-properties packageName=pyfx.dispatch.oanda.api --additional-properties packageVersion=3.0.25 --additional-properties pythonSrcRoot=api --additional-properties  testsUsePythonSrcRoot=true   -i ${HERE}/build/v20-openapi-3.0.25/json/v20.json --invoker-package pyfx.dispatch.oanda.api --skip-validate-spec -pnoservice

