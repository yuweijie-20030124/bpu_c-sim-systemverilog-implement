#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "stdint.h"
#include "cJSON.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

extern int bp_sim_no_bp(FILE *bin_fp, FILE *db_fp, cJSON *conf_json);
extern int bp_sim_always_yes_bp(FILE *bin_fp, FILE *db_fp, cJSON *conf_json);
extern int bp_sim_two_bit_saturating_counter_bp(FILE *bin_fp, FILE *db_fp, cJSON *conf_json);
extern int bp_sim_two_bit_saturating_counter_with_BTB_bp(FILE *bin_fp, FILE *db_fp, cJSON *conf_json);
typedef int (*test_fn)(FILE *bin_fp, FILE *db_fp, cJSON *conf_json);

test_fn test_funcs[] = {bp_sim_no_bp, bp_sim_always_yes_bp, bp_sim_two_bit_saturating_counter_bp, bp_sim_two_bit_saturating_counter_with_BTB_bp};

int main(int argc, char const *argv[]){
    return 0;
}