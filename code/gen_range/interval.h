#ifndef INTERVAL_H
#define INTERVAL_H

#include "tools.h"

#include <set>
#include <tuple>

#include <iostream>
#include <fstream>


#define MAX(x, y) ( ((x) > (y))? (x):(y) )
#define MIN(x, y) ( ((x) < (y))? (x):(y) )

struct interval{
    double lbound;
    double ubound;
    bool is_valid;
};

extern struct interval id_valid;
extern struct interval id_invalid;
extern struct commutative_ring interval_ring;

void print_interval(struct interval a);
bool eq_interval(struct interval a, struct interval b);
bool valid(struct interval a);
void update_validity(struct interval *a);

struct interval interval_from_int32(int32_t a);
struct interval interval_from_int64(int64_t a);
struct interval interval_from_double(double a);
struct interval interval_ranged_from_int32(int32_t a);
struct interval interval_ranged_from_int64(int64_t a);
struct interval interval_ranged_from_double_pair(double a, double b);

struct interval interset(struct interval a, struct interval b);


extern std::set<interval> all_interval;
extern std::set< std::tuple<interval, interval, interval> > add_interval, mul_interval;

inline bool operator<(const interval& a, const interval& b){
    if(a.lbound == b.lbound){
        return a.ubound < b.ubound;
    }
    return a.lbound < b.lbound;
}

inline bool operator==(const interval& a, const interval& b){
    if( (a.lbound == b.lbound) && (a.ubound == b.ubound) ){
        return true;
    }
    return false;
}

inline bool operator<(const std::tuple<interval, interval, interval>& a, const std::tuple<interval, interval, interval> b){
    if(std::get<0>(a) == std::get<0>(b)){
        if(std::get<1>(a) == std::get<1>(b)){
            return std::get<2>(a) < std::get<2>(b);
        }
        return std::get<1>(a) < std::get<1>(b);
    }
    return std::get<0>(a) < std::get<0>(b);
}

void print_f_interval(const std::tuple<interval, interval, interval>& a);
void print_interval_set(const std::set< std::tuple<interval, interval, interval> >& a);

#endif

