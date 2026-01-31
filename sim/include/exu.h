#ifndef __EXU_H__
#define __EXU_H__

#include "stdio.h"
#include "ftq.h"
#include "test_base.h"
#include "ifu.h"

class exu_class{
private:
    ftq_class       &ftq;
    test_base_class &test;
    FILE            *db_fp;
    uint32_t        predict_bit_size;
    ifu_class       &ifu;
public:
    exu_class(ftq_class &ftq_i, test_base_class &test_i, FILE *fp, uint32_t predict_bit_size_i, ifu_class &ifu_i);
    ~exu_class();
    bool execute(uint64_t &inst_cnt, uint64_t &pred_miss);
};

#endif

