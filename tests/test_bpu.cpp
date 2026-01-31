#include "../cpp_sim/two_bit_counter.h"
#include "../cpp_sim/btb.h"
#include "../cpp_sim/bpu.h"
#include <iostream>
#include <iomanip>
#include <cassert>

// Test 2-bit counter
void test_two_bit_counter() {
    std::cout << "Testing 2-bit Saturating Counter..." << std::endl;
    
    TwoBitCounter counter;
    
    // Initial state should be 10 (weakly taken)
    assert(counter.get_value() == 2);
    assert(counter.predict() == true);
    
    // Test saturation at upper bound
    counter.update(true);  // 10 -> 11
    assert(counter.get_value() == 3);
    counter.update(true);  // 11 -> 11 (saturate)
    assert(counter.get_value() == 3);
    
    // Test transition to not taken
    counter.update(false); // 11 -> 10
    assert(counter.get_value() == 2);
    counter.update(false); // 10 -> 01
    assert(counter.get_value() == 1);
    assert(counter.predict() == false);
    counter.update(false); // 01 -> 00
    assert(counter.get_value() == 0);
    
    // Test saturation at lower bound
    counter.update(false); // 00 -> 00 (saturate)
    assert(counter.get_value() == 0);
    
    // Test transition back to taken
    counter.update(true);  // 00 -> 01
    assert(counter.get_value() == 1);
    counter.update(true);  // 01 -> 10
    assert(counter.get_value() == 2);
    assert(counter.predict() == true);
    
    std::cout << "  2-bit Counter tests PASSED" << std::endl;
}

// Test BTB
void test_btb() {
    std::cout << "Testing Branch Target Buffer..." << std::endl;
    
    BTB btb(256);
    
    uint32_t pc1 = 0x1000;
    uint32_t target1 = 0x2000;
    uint32_t pc2 = 0x1004;
    uint32_t target2 = 0x3000;
    
    uint32_t result;
    
    // Initially, no hits
    assert(btb.lookup(pc1, result) == false);
    
    // Update BTB
    btb.update(pc1, target1);
    
    // Should hit now
    assert(btb.lookup(pc1, result) == true);
    assert(result == target1);
    
    // Add another entry
    btb.update(pc2, target2);
    assert(btb.lookup(pc2, result) == true);
    assert(result == target2);
    
    // First entry should still be there
    assert(btb.lookup(pc1, result) == true);
    assert(result == target1);
    
    // Clear BTB
    btb.clear();
    assert(btb.lookup(pc1, result) == false);
    assert(btb.lookup(pc2, result) == false);
    
    std::cout << "  BTB tests PASSED" << std::endl;
}

// Test BPU
void test_bpu() {
    std::cout << "Testing Branch Prediction Unit..." << std::endl;
    
    BPU bpu(1024, 256);
    
    uint32_t pc = 0x1000;
    uint32_t target = 0x2000;
    
    // Make initial prediction
    BPU::Prediction pred = bpu.predict(pc);
    assert(pred.taken == true);  // Should predict taken initially
    assert(pred.target_valid == false);  // No BTB entry yet
    
    // Update with actual taken branch
    bpu.update(pc, true, target);
    
    // Predict again
    pred = bpu.predict(pc);
    assert(pred.taken == true);
    assert(pred.target_valid == true);  // BTB should have entry now
    assert(pred.target == target);
    
    // Train counter to not taken (3 updates: 11->10->01->00)
    for (int iter = 0; iter < 3; iter++) {
        bpu.update(pc, false, 0);
    }
    
    pred = bpu.predict(pc);
    assert(pred.taken == false);  // Should predict not taken now
    
    std::cout << "  BPU tests PASSED" << std::endl;
}

// Simple branch trace simulation
void test_branch_trace() {
    std::cout << "Testing with simple branch trace..." << std::endl;
    
    BPU bpu(1024, 256);
    
    // Simulate a loop that iterates 10 times
    uint32_t loop_pc = 0x1000;
    uint32_t loop_target = 0x1000;  // Loop back
    uint32_t exit_target = 0x2000;  // Exit loop
    
    int correct = 0;
    int total = 0;
    
    for (int i = 0; i < 10; i++) {
        BPU::Prediction pred = bpu.predict(loop_pc);
        bool actually_taken = (i < 9);  // Taken 9 times, not taken on last iteration
        uint32_t actual_target = actually_taken ? loop_target : exit_target;
        
        if (pred.taken == actually_taken) {
            correct++;
        }
        total++;
        
        bpu.update(loop_pc, actually_taken, actual_target);
    }
    
    double accuracy = (double)correct / total * 100.0;
    std::cout << "  Accuracy: " << correct << "/" << total 
              << " (" << std::fixed << std::setprecision(1) << accuracy << "%)" << std::endl;
    
    std::cout << "  Branch trace test PASSED" << std::endl;
}

int main() {
    std::cout << "======================================" << std::endl;
    std::cout << "BPU Test Suite" << std::endl;
    std::cout << "======================================" << std::endl;
    
    test_two_bit_counter();
    test_btb();
    test_bpu();
    test_branch_trace();
    
    std::cout << "======================================" << std::endl;
    std::cout << "All tests PASSED!" << std::endl;
    std::cout << "======================================" << std::endl;
    
    return 0;
}
