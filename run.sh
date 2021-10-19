#! /bin/sh

#set -o errexit # TODO: enable this check
set -o nounset
set -o xtrace

FILE_LIST=`find ./src -name "*v"`
# Format check
docker run --rm -v `pwd`:`pwd` -w `pwd` --entrypoint verible-verilog-format ghcr.io/chipsalliance/verible-linter-action --failsafe_success=false --inplace --verbose $FILE_LIST
git diff --exit-code # Fail if any format change
# Lint check
docker run --rm -v `pwd`:`pwd` -w `pwd` --entrypoint verible-verilog-lint ghcr.io/chipsalliance/verible-linter-action --ruleset=all --show_diagnostic_context $FILE_LIST

BUILD_DIR=build
SIM_ELF=a.out
SIM_ELF_PATH=$BUILD_DIR/$SIM_ELF
mkdir -p $BUILD_DIR
docker run --rm -v `pwd`:`pwd` -w `pwd` -u root 0x01be/iverilog iverilog -g2012 -o $SIM_ELF_PATH -I ./src ./src/testbench.v
cd $BUILD_DIR
docker run --rm -v `pwd`:`pwd` -w `pwd` -u root 0x01be/iverilog ./$SIM_ELF

