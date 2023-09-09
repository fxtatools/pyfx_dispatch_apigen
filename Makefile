## GNU Makefile for PyFX::Dispatch::APIGen

BUILDDIR?=			${CURDIR}/build
SCRIPTSDIR?=			${BUILDDIR}/scripts
FETCHDIR?=			${CURDIR}/fetch

OPENAPI_GENERATOR_SH?=		openapi-generator-cli.sh
OPENAPI_GENERATOR_DIST?=	https://raw.githubusercontent.com/OpenAPITools/openapi-generator/master/bin/utils/${OPENAPI_GENERATOR_SH}

PYTHON?=			$(shell if which python3; then echo python3; else echo python; fi)
PYVENV_DIR?=			env
REQUIREMENTS_IN?=		requirements.in
REQUIREMENTS_TXT?=		requirements.txt
PYVENV_DEPS?=			${PYVENV_DIR}/pyvenv.cfg
PROJECT_PY?=			project.py
FETCH?=				${PYTHON} ${PROJECT_PY} fetch
FETCH_DEPS?=			${PROJECT_PY}

PACKAGE_BASENAME?=		pyfx.dispatch
PROJECT_BASENAME?=		pyfx_dispatch
PROJECT_VERSION?=		1.0.0

OANDA_VERSION?=			3.0.25
OANDA_DISTFILE?=		https://github.com/oanda/v20-openapi/archive/refs/tags/${OANDA_VERSION}.zip
OANDA_LOCAL?=			oanda_${OANDA_VERSION}.zip
OANDA_EXTRACTDIR?=		v20-openapi-${OANDA_VERSION}
OANDA_SPEC?=			json/v20.json
OANDA_PROPS?=			library=asyncio disallowAdditionalPropertiesIfNotPresent=false \
				packageName=${PACKAGE_BASENAME}.oanda packageVersion=${PROJECT_VERSION} \
				projectName=${PROJECT_BASENAME}_oanda
OANDA_ARGS?=			--invoker-package ${PACKAGE_BASENAME}.oanda --skip-validate-spec
OANDA_GEN?=			python

UNZIP?=				unzip

all:

fetch: ${SCRIPTSDIR}/${OPENAPI_GENERATOR_SH} ${FETCHDIR}/${OANDA_LOCAL}

env: ${PYVENV_DIR}/pyvenv.cfg

projects: ${BUILDDIR}/oanda/pyproject.toml

${PYVENV_DIR}/pyvenv.cfg:
	if ! [ -d "${PYVENV_DIR}" ]; then ${PYTHON} ${PROJECT_PY} ensure_env ${PYVENV_DIR}; fi

${REQUIREMENTS_TXT}:		${REQUIREMENTS_IN}

${SCRIPTSDIR}/${OPENAPI_GENERATOR_SH}: ${FETCH_DEPS}
	mkdir -p ${SCRIPTSDIR}
	if ! [ -e "$@" ]; then ${FETCH} "${OPENAPI_GENERATOR_DIST}" "$@"; fi
	chmod +x "$@"


${FETCHDIR}/${OANDA_LOCAL}: ${FETCH_DEPS}
	mkdir -p ${FETCHDIR}
	if ! [ -e "$@" ]; then ${FETCH} "${OANDA_DISTFILE}" "$@"; fi
	chmod +x "$@"

${BUILDDIR}/${OANDA_EXTRACTDIR}/${OANDA_SPEC}: ${FETCHDIR}/${OANDA_LOCAL}
	if ! [ -e "$@" ]; then ${UNZIP} -d "${BUILDDIR}" "${FETCHDIR}/${OANDA_LOCAL}"; fi

${BUILDDIR}/oanda/pyproject.toml: ${BUILDDIR}/${OANDA_EXTRACTDIR}/${OANDA_SPEC} ${SCRIPTSDIR}/${OPENAPI_GENERATOR_SH}
	mkdir -p $(@D); cd $(@D); ${SCRIPTSDIR}/${OPENAPI_GENERATOR_SH} generate -g ${OANDA_GEN} \
		-i "${BUILDDIR}/${OANDA_EXTRACTDIR}/${OANDA_SPEC}" ${OANDA_ARGS} \
		$(foreach P,${OANDA_PROPS},--additional-properties ${P})
	@echo "project files generated in $(@D)" 1>&2

realclean:
	rm -rfv ${SCRIPTSDIR}/*.jar "${SCRIPTSDIR}/${OPENAPI_GENERATOR_SH}" "${FETCHDIR}/${OANDA_LOCAL}" "${BUILDDIR}/${OANDA_EXTRACTDIR}"


