#ifndef __IFU_H__
#define __IFU_H__

#include "decode.h"
#include "ftq.h"
#include "test_base.h"

typedef struct {
    ftb_entry   new_entry;
    bool        update;
}precheck_result;

class ifu_class{
private:
    predecode_result decode_result;
    precheck_result  check_result;
    ftq_class       &ftq;
    uint8_t         *mmap_ptr;
    uint64_t         pc_bias;
public:
    ifu_class(bool rvi_valid, ftq_class &ftq_i, uint8_t *mmap_ptr_i, uint64_t pc_bias_i);
    ~ifu_class();
    void set_rvi_status(bool rvi_valid);
    bool get_rvi_status();
    void fetch_code_check(uint32_t tag_start_bit, uint32_t tag_bit_size, uint32_t predict_bit_size, uint32_t predict_size);
};


#endif
