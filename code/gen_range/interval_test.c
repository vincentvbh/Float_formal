
#include <stdio.h>
#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include <memory.h>

#include <iostream>
#include <fstream>
#include <sstream>

#include <set>
#include <tuple>

std::ifstream inf;
std::ofstream outf;
std::stringstream mul_core, add_core;

#include "tools.h"
#include "naive_mult.h"
#include "ntt_c.h"
#include "gen_table.h"

#include "interval.h"
#include "float_FFT.h"

void print_condition(const interval& a, char c);
void fprint_condition(std::ofstream& outfile, const interval& a, char c);
void femit_conditions(std::ofstream& outfile, std::stringstream& core_string, const std::set< std::tuple<interval, interval, interval> >& a);

int main(void){

    int64_t poly1[1024], poly2[1024];
    int64_t res[1024];
    fpr fpoly1[1024], fpoly2[1024];
    fpr fres[1024];
    int64_t t;
    interval max_interval;

    struct interval poly_interval[1024];

    for(size_t i = 0; i < 1024; i++){
        poly_interval[i] = interval_ranged_from_int64(32768);
    }

    for(size_t i = 0; i < 2048; i++){
        twiddle_interval[i] = interval_from_double(fpr_gm_tab[i].v);
    }

    FFT_interval(poly_interval, 10);

    max_interval.lbound = max_interval.ubound = 1.0;

    for(size_t i = 0; i < 1024; i++){
        max_interval.lbound = MIN(max_interval.lbound, poly_interval[i].lbound);
        max_interval.ubound = MAX(max_interval.ubound, poly_interval[i].ubound);
    }

    for(auto it = all_interval.begin(); it != all_interval.end(); ++it){
        max_interval.lbound = MIN(max_interval.lbound, (*it).lbound);
        max_interval.ubound = MAX(max_interval.ubound, (*it).ubound);
    }

    print_condition(max_interval, '0');

    std::cout << "Minimum lower bound:" << std::endl << max_interval.lbound << std::endl;
    std::cout << "Maximum upper bound:" << std::endl << max_interval.ubound << std::endl;

    std::cout << "Number of intervals:" << std::endl << all_interval.size() << std::endl;
    std::cout << "Number of intervals for addition/subtractions:" << std::endl << add_interval.size() << std::endl;
    std::cout << "Number of intervals for multiplications:" << std::endl << mul_interval.size() << std::endl;

    inf.open("mul_core.txt");
    mul_core << inf.rdbuf();
    inf.close();
    inf.open("add_core.txt");
    add_core << inf.rdbuf();
    inf.close();

    outf.open("../CL/mul_range.cl");
    femit_conditions(outf, mul_core, mul_interval);
    outf.close();

    outf.open("../CL/add_range.cl");
    femit_conditions(outf, add_core, add_interval);
    outf.close();

}

void print_condition(const interval& a, char c){

    uint64_t al, au;
    al = *(uint64_t*)&a.lbound; au = *(uint64_t*)&a.ubound;
    uint64_t el, ml, eu, mu;
    el = al >> 52; ml = al & 0xfffffffffffff;
    eu = au >> 52; mu = au & 0xfffffffffffff;

    std::cout << "or[ " << el << "@11 < e" << c <<
                 ", and[" << el << "@11 = e" << c << ", " << ml << "@52 <= m" << c << " ] ] " << std::endl;
    std::cout << "or[ " << eu << "@11 > e" << c <<
                 ", and[" << eu << "@11 = e" << c << ", " << mu << "@52 >= m" << c << " ] ] " << std::endl;

}

void fprint_condition(std::ofstream& outfile, const interval& a, char c){

    uint64_t al, au;
    al = *(uint64_t*)&a.lbound; au = *(uint64_t*)&a.ubound;
    uint64_t el, ml, eu, mu;
    el = al >> 52; ml = al & 0xfffffffffffff;
    eu = au >> 52; mu = au & 0xfffffffffffff;

    outfile << "        ";
    outfile << "or[ " << el << "@11 < e" << c <<
               ", and[" << el << "@11 = e" << c << ", " << ml << "@52 <= m" << c << " ] ], " << std::endl;
    outfile << "        ";
    outfile << "or[ " << eu << "@11 > e" << c <<
               ", and[" << eu << "@11 = e" << c << ", " << mu << "@52 >= m" << c << " ] ] ";

}

void femit_conditions(std::ofstream& outfile, std::stringstream& core_string, const std::set< std::tuple<interval, interval, interval> >& a){

    uint64_t t;

    for(auto it = a.begin(); it != a.end(); ++it){
        outfile << std::endl;
        outfile << "proc main";
        t = *(uint64_t*)&(std::get<0>(*it).lbound); outfile << t;
        t = *(uint64_t*)&(std::get<0>(*it).ubound); outfile << t;
        t = *(uint64_t*)&(std::get<1>(*it).lbound); outfile << t;
        t = *(uint64_t*)&(std::get<1>(*it).ubound); outfile << t;
        t = *(uint64_t*)&(std::get<2>(*it).lbound); outfile << t;
        t = *(uint64_t*)&(std::get<2>(*it).ubound); outfile << t;
        outfile << "(uint1 s0, uint11 e0, uint52 m0, uint1 s1, uint11 e1, uint52 m1, uint1 sr, uint11 er, uint52 mr) =" << std::endl
                << "{ \n    true \n        && \n    and[" << std::endl;
        fprint_condition(outfile, std::get<1>(*it), '0');
        outfile << "," << std::endl;
        fprint_condition(outfile, std::get<2>(*it), '1');
        outfile << std::endl;
        outfile << "    ]" << std::endl << "}" << std::endl;
        outfile << core_string.str();
        outfile << "{ \n    true \n        && \n    or[    \n    and[" << std::endl;
        fprint_condition(outfile, std::get<0>(*it), 'r');
        outfile << std::endl;
        outfile << "    ],\n        and[0@11 = er, 0@52 = mr]\n    ]\n}" << std::endl << std::endl;
    }

}


