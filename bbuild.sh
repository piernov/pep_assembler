#!/bin/bash

flex main-scanner.ll
bison --debug --verbose main-parser.yy -k -o main-parser.cc
c++ -g -c lex.yy.c -o lex.yy.o
c++ -g lex.yy.o main-parser.cc -o main
