#ifndef __DECODE_H__
#define __DECODE_H__

#include "stdint.h"

typedef struct {
    bool        is_branch;
    bool        is_jal;
    uint32_t    branch_addr;
    bool        is_call;
    bool        is_ret;
    bool        is_jalr;
    uint32_t    offset;
    bool        is_rvc;
    uint32_t    inst_pc;
    uint32_t    inst;
}inst_decode;

#define DECODE_CNT 32

typedef struct {
    uint32_t    cnt;
    inst_decode decode[DECODE_CNT];
    bool        rvi_valid;
    bool        has_one_branch;
    uint32_t    one_branch_index;
    bool        has_two_branch;
    uint32_t    two_branch_index;
    bool        has_three_branch;
    uint32_t    three_branch_index;
    bool        has_jump;
    uint32_t    jump_index;
}predecode_result;

void predecode(uint8_t *ptr, uint32_t predict_size, uint32_t start_pc, predecode_result *decode_result);

#endif