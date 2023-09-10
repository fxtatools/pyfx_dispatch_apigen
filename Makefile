## GNU Makefile for PyFX::Dispatch::APIGen

BUILDDIR?=		${CURDIR}/build
SCRIPTSDIR?=		${BUILDDIR}/scripts
FETCHDIR?=		${CURDIR}/fetch

GENERATOR_SH?=		openapi-generator-cli.sh
GENERATOR_DIST?=	https://raw.githubusercontent.com/OpenAPITools/openapi-generator/master/bin/utils/${GENERATOR_SH}

PYTHON?=		$(shell if which python3; then echo python3; else echo python; fi)
PYVENV_DIR?=		env
REQUIREMENTS_IN?=	requirements.in
REQUIREMENTS_TXT?=	requirements.txt
REQUIREMENTS_DEPS?=	${REQUIREMENTS_IN} requirements-dev.txt $(wildcard requirements.local)
PYVENV_DEPS?=		${PYVENV_DIR}/pyvenv.cfg
PROJECT_PY?=		project.py

PYVENV_BINDIR?=		$(shell if [ -e "${PYVENV_DIR}/Scripts" ]; then echo "${PYVENV_DIR}/Scripts"; else echo "${PYVENV_DIR}/bin"; fi)

FETCH?=			${PYTHON} ${PROJECT_PY} fetch
FETCH_DEPS?=		${PROJECT_PY}

PACKAGE_BASENAME?=	pyfx.dispatch
PROJECT_BASENAME?=	pyfx_dispatch
PROJECT_VERSION?=	1.0.0

OANDA_VERSION?=		3.0.25
OANDA_DISTFILE?=	https://github.com/oanda/v20-openapi/archive/refs/tags/${OANDA_VERSION}.zip
OANDA_LOCAL?=		oanda_${OANDA_VERSION}.zip
OANDA_EXTRACTDIR?=	v20-openapi-${OANDA_VERSION}
OANDA_SPEC?=		json/v20.json
OANDA_PROPS?=		library=asyncio disallowAdditionalPropertiesIfNotPresent=false \
			packageName=${PACKAGE_BASENAME}.oanda packageVersion=${PROJECT_VERSION} \
			projectName=${PROJECT_BASENAME}_oanda
OANDA_ARGS?=		--invoker-package ${PACKAGE_BASENAME}.oanda --skip-validate-spec
OANDA_GEN?=		python

UNZIP?=			unzip

all: sync

fetch: ${SCRIPTSDIR}/${GENERATOR_SH} ${FETCHDIR}/${OANDA_LOCAL}

env: ${PYVENV_DIR}/pyvenv.cfg

projects: ${BUILDDIR}/oanda/pyproject.toml

requirements: ${REQUIREMENTS_TXT}

${PYVENV_DIR}/pyvenv.cfg:
	if ! [ -e "${PYVENV_DIR}" ]; then \
		${PYTHON} ${PROJECT_PY} ensure_env ${PYVENV_DIR}; \
		${PYVENV_BINDIR}/pip ${PIP_ARGS} install --upgrade pip wheel; \
	fi

${PYVENV_BINDIR}/pip-compile: ${PYVENV_DIR}/pyvenv.cfg
	if ! [ -e "${@}" ]; then ${PYVENV_BINDIR}/pip ${PIP_ARGS} install pip-tools; fi

${REQUIREMENTS_TXT}: ${REQUIREMENTS_DEPS} ${PYVENV_BINDIR}/pip-compile
	${PYVENV_BINDIR}/pip-compile -v --pip-args "${PIP_ARGS}" -o $@ ${REQUIREMENTS_DEPS}

sync: ${REQUIREMENTS_TXT} ${PYVENV_BINDIR}/pip-compile
## --no-build-isolation may prevent errors during tmpdir deletion on Windows
	${PYVENV_BINDIR}/pip-sync -v --pip-args "--no-build-isolation ${PIP_ARGS}"

${SCRIPTSDIR}/${GENERATOR_SH}: ${FETCH_DEPS}
	mkdir -p ${SCRIPTSDIR}
	if ! [ -e "$@" ]; then ${FETCH} "${GENERATOR_DIST}" "$@"; fi
	chmod +x "$@"

${FETCHDIR}/${OANDA_LOCAL}: ${FETCH_DEPS}
	mkdir -p ${FETCHDIR}
	if ! [ -e "$@" ]; then ${FETCH} "${OANDA_DISTFILE}" "$@"; fi
	chmod +x "$@"

${BUILDDIR}/${OANDA_EXTRACTDIR}/${OANDA_SPEC}: ${FETCHDIR}/${OANDA_LOCAL}
## FIXME use stdlib 'zipfile' in project.py
	if ! [ -e "$@" ]; then ${UNZIP} -d "${BUILDDIR}" "${FETCHDIR}/${OANDA_LOCAL}"; fi

${BUILDDIR}/oanda/pyproject.toml: ${BUILDDIR}/${OANDA_EXTRACTDIR}/${OANDA_SPEC} ${SCRIPTSDIR}/${GENERATOR_SH}
	mkdir -p $(@D); cd $(@D); ${SCRIPTSDIR}/${GENERATOR_SH} generate -g ${OANDA_GEN} \
		-i "${BUILDDIR}/${OANDA_EXTRACTDIR}/${OANDA_SPEC}" ${OANDA_ARGS}" \
		$(foreach P,${OANDA_PROPS},--additional-properties ${P})
	@echo "project files generated in $(@D)" 1>&2

realclean:
	rm -rfv ${SCRIPTSDIR}/*.jar "${SCRIPTSDIR}/${GENERATOR_SH}" "${FETCHDIR}/${OANDA_LOCAL}" "${BUILDDIR}/${OANDA_EXTRACTDIR}"




