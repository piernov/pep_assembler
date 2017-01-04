#!/bin/bash

flex main-scanner.ll
bison main-parser.yy -k -o main-parser.cc
c++ -g -c lex.yy.c -o lex.yy.o
c++ -g lex.yy.o main-parser.cc translator.cpp printer.cpp -o pep_assembler
