#!/bin/bash

BASE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
rm -rf $BASE_DIR/.dist
mkdir $BASE_DIR/.dist

cd $BASE_DIR/data_generator_fa
npm run build
cd $BASE_DIR/data_generator_fa/.dist/
zip -r $BASE_DIR/.dist/data_generator_fa.zip .