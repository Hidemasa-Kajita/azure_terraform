#!/bin/bash

## cd やめたい
cd `pwd`/$2

terraform $1

cd ..