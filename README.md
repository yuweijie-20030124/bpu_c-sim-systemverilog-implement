# BPU C++ Simulation & SystemVerilog Implementation

This repository contains both C++ simulation and SystemVerilog hardware description implementations of a Branch Prediction Unit (BPU) with:
- **2-bit Saturating Counter**: For branch direction prediction
- **Branch Target Buffer (BTB)**: For branch target address prediction

## Architecture Overview

### 2-bit Saturating Counter
The 2-bit saturating counter implements a simple branch predictor with four states:
- `00` - Strongly Not Taken
- `01` - Weakly Not Taken
- `10` - Weakly Taken (initial state)
- `11` - Strongly Taken

The counter predicts "taken" when the value is ≥ 2, and increments/decrements based on actual branch outcomes while saturating at the boundaries.

### Branch Target Buffer (BTB)
The BTB is a cache that stores mappings from branch instruction addresses (PC) to their target addresses. It uses:
- Direct-mapped organization with configurable size
- Tag-based matching for collision detection
- Efficient lookup for predicting branch targets

### Branch Prediction Unit (BPU)
The BPU combines both components:
- Uses 2-bit counters for direction prediction
- Uses BTB for target address prediction
- Provides both prediction and update interfaces
- Tracks statistics (accuracy, BTB hit rate)

## Directory Structure

```
├── cpp_sim/              # C++ implementation
│   ├── two_bit_counter.h # 2-bit counter class
│   ├── btb.h             # Branch Target Buffer class
│   └── bpu.h             # Complete BPU class
├── systemverilog/        # SystemVerilog implementation
│   ├── two_bit_counter.sv # 2-bit counter module
│   ├── btb.sv            # BTB module
│   └── bpu.sv            # Complete BPU module
├── tests/                # Test files
│   ├── test_bpu.cpp      # C++ unit tests
│   ├── tb_two_bit_counter.sv # Counter testbench
│   ├── tb_btb.sv         # BTB testbench
│   └── tb_bpu.sv         # BPU testbench
└── Makefile              # Build system
```

## Requirements

### For C++ Simulation
- C++ compiler with C++11 support (e.g., g++ 4.8+)

### For SystemVerilog Simulation
- Icarus Verilog (iverilog) or compatible SystemVerilog simulator
- Install on Ubuntu/Debian: `sudo apt-get install iverilog`

## Building and Testing

### Run All Tests
```bash
make test
```

### Run C++ Tests Only
```bash
make test-cpp
```

### Run SystemVerilog Tests Only
```bash
make test-sv
```

### Run Individual SystemVerilog Tests
```bash
make test-sv-counter  # Test 2-bit counter
make test-sv-btb      # Test BTB
make test-sv-bpu      # Test complete BPU
```

### Clean Build Artifacts
```bash
make clean
```

## Usage Examples

### C++ API Example

```cpp
#include "cpp_sim/bpu.h"

// Create BPU with 1024 counters and 256 BTB entries
BPU bpu(1024, 256);

// Make a prediction
uint32_t pc = 0x1000;
BPU::Prediction pred = bpu.predict(pc);

if (pred.taken) {
    if (pred.target_valid) {
        // Use predicted target
        next_pc = pred.target;
    } else {
        // Need to wait for target computation
    }
}

// Update with actual outcome
bpu.update(pc, actually_taken, actual_target);

// Get statistics
double accuracy = bpu.get_accuracy();
double btb_hit_rate = bpu.get_btb_hit_rate();
```

### SystemVerilog Module Instantiation

```systemverilog
bpu #(
    .COUNTER_INDEX_WIDTH(10),  // 1024 counters
    .BTB_INDEX_WIDTH(8),       // 256 BTB entries
    .ADDR_WIDTH(32)
) bpu_inst (
    .clk(clk),
    .rst_n(rst_n),
    // Prediction interface
    .pred_pc(pred_pc),
    .pred_taken(pred_taken),
    .pred_target_valid(pred_target_valid),
    .pred_target(pred_target),
    // Update interface
    .update_en(update_en),
    .update_pc(update_pc),
    .update_taken(update_taken),
    .update_target(update_target)
);
```

## Configuration Parameters

### C++ Implementation
- **TwoBitCounter**: Single counter with 2-bit state
- **BTB**: Configurable number of entries (default: 256)
- **BPU**: Configurable counters (default: 1024) and BTB entries (default: 256)

### SystemVerilog Implementation
- **two_bit_counter**: Single counter module
- **btb**: Parameterized with INDEX_WIDTH (default: 8 = 256 entries)
- **bpu**: Parameterized with COUNTER_INDEX_WIDTH (default: 10 = 1024 counters) and BTB_INDEX_WIDTH (default: 8 = 256 entries)

## License

This is an educational implementation for learning about branch prediction mechanisms.
