
#include "interval.h"

#include <stdint.h>
#include <stddef.h>
#include <stdio.h>
#include <memory.h>
#include <stdlib.h>

struct interval id_valid = {
    .lbound = 0.0,
    .ubound = 0.0,
    .is_valid = 1
};

struct interval id_invalid = {
    .lbound = 0.0,
    .ubound = 0.0,
    .is_valid = 0
};

void memberZ(void *des, void *src){
    memmove(des, src, sizeof(struct interval));
    update_validity((struct interval*)des);
    return;
}

void addZ(void *des, void *src1, void *src2){
    struct interval a = *(struct interval*)src1;
    struct interval b = *(struct interval*)src2;
    struct interval c = interset(a, b);

    struct interval t;

    uint64_t u64_t;
    double f64l_t, f64h_t;

    if(eq_interval(c, id_invalid)){
        *(struct interval*)des = c;
        all_interval.insert(c);
        add_interval.insert(std::make_tuple(c, a, b));
        return;
    }

    if(eq_interval(c, id_valid)){
        f64l_t = a.ubound - b.lbound;
        f64h_t = b.ubound - a.lbound;
        if(f64l_t < 0.0){
            f64l_t = -f64l_t;
        }
        if(f64h_t < 0.0){
            f64h_t = -f64h_t;
        }
        t.lbound = MIN(f64l_t, f64h_t);
        t.ubound = a.ubound + b.ubound;
    }else{
        u64_t = *(uint64_t*)&c.lbound;
        u64_t = ((u64_t >> 52) - 52) << 52;
        t.lbound = *(double*)(&u64_t);
        t.ubound = a.ubound + b.ubound;
    }

    t.lbound = MIN(t.lbound, a.lbound);
    t.lbound = MIN(t.lbound, b.lbound);

    update_validity(&t);

    *(struct interval*)des = t;
    all_interval.insert(t);
    add_interval.insert(std::make_tuple(t, a, b));

    return;
}

void subZ(void *des, void *src1, void *src2){
    addZ(des, src1, src2);
    return;
}

void mulZ(void *des, void *src1, void *src2){
    struct interval a = *(struct interval*)src1;
    struct interval b = *(struct interval*)src2;
    struct interval t;

    if( (valid(a) == 0) || (valid(b) == 0) ){
        *(struct interval*)des = id_invalid;
        all_interval.insert(id_invalid);
        mul_interval.insert(std::make_tuple(id_invalid, a, b));
        return;
    }

    t.lbound = a.lbound * b.lbound;
    t.ubound = a.ubound * b.ubound;
    update_validity(&t);

    *(struct interval*)des = t;
    all_interval.insert(t);
    mul_interval.insert(std::make_tuple(t, a, b));

    return;
}

void expZ(void *des, void *src, size_t e){
    return;
}

struct commutative_ring interval_ring = {
    .sizeZ = sizeof(struct interval),
    .memberZ = memberZ,
    .addZ = addZ,
    .subZ = subZ,
    .mulZ = mulZ,
    .expZ = expZ
};

std::set<interval> all_interval;
std::set< std::tuple<interval, interval, interval> > add_interval, mul_interval;

void print_interval(struct interval a){

    uint64_t al, au;
    al = *(uint64_t*)&a.lbound;
    au = *(uint64_t*)&a.ubound;

    printf("validity = %d\n"
            "flbound = %10lf, fubound = %10lf\n"
            "llxlbound = %16llx, llxubound = %16llx\n"
            "elbound = %16llu, slbound = %16llu; eubound = %16llu, subound = %16llu\n"
            ,
            a.is_valid,
            a.lbound, a.ubound,
            al, au,
            al >> 52, (1ULL << 52) + (al & 0xfffffffffffff),
            au >> 52, (1ULL << 52) + (au & 0xfffffffffffff));

}

bool eq_interval(struct interval a, struct interval b){
    if(memcmp(&a, &b, sizeof(struct interval)) == 0){
        return 1;
    }
    return 0;
}

bool valid(struct interval a){

    if(a.lbound < 0.0){
        return 0;
    }
    if(a.ubound < 0.0){
        return 0;
    }
    if(a.lbound > a.ubound){
        return 0;
    }
    return 1;

}

void update_validity(struct interval *a){
    a->is_valid = valid(*a);
}

struct interval interval_from_int32(int32_t a){

    struct interval t;

    if(a < 0){
        a = -a;
    }

    t.lbound = t.ubound = (double)a;
    t.is_valid = 1;

    return t;

}

struct interval interval_from_int64(int64_t a){

    struct interval t;

    if(a < 0){
        a = -a;
    }

    t.lbound = t.ubound = (double)a;
    t.is_valid = 1;

    return t;

}

struct interval interval_from_double(double a){

    struct interval t;

    if(a < 0.0){
        a = -a;
    }

    t.lbound = t.ubound = a;
    t.is_valid = 1;

    return t;

}

struct interval interval_ranged_from_int32(int32_t a){

    struct interval t;

    if(a < 0){
        a = -a;
    }

    t.lbound = 1;
    t.ubound = (double)a;
    t.is_valid = 1;

    return t;

}

struct interval interval_ranged_from_int64(int64_t a){

    struct interval t;

    if(a < 0){
        a = -a;
    }

    t.lbound = 1;
    t.ubound = (double)a;
    t.is_valid = 1;

    return t;

}

struct interval interval_ranged_from_double_pair(double a, double b){

    struct interval t;

    if(a < 0.0){
        a = -a;
    }
    if(b < 0.0){
        b = -b;
    }

    t.lbound = MIN(a, b);
    t.ubound = MAX(a, b);
    update_validity(&t);

    return t;

}

struct interval interset(struct interval a, struct interval b){

    struct interval t;

    if( (valid(a) == 0) || (valid(b) == 0) ){
        return id_invalid;
    }

    if(a.lbound > b.lbound){
        return interset(b, a);
    }

    if(a.ubound < b.lbound){
        return id_valid;
    }

    t.lbound = b.lbound;

    if(a.ubound > b.ubound){
        t.ubound = b.ubound;
    }else{
        t.ubound = a.ubound;
    }

    t.is_valid = 1;

    return t;

}

void print_f_interval(const std::tuple<interval, interval, interval>& a){

    std::cout << "Interval start" << std::endl;

    print_interval(std::get<0>(a));
    print_interval(std::get<1>(a));
    print_interval(std::get<2>(a));

    std::cout << "Interval end" << std::endl;

}

void print_interval_set(const std::set< std::tuple<interval, interval, interval> >& a){

    for(auto it = a.begin(); it != a.end(); ++it){
        print_f_interval(*it);
    }

}



