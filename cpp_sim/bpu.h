#ifndef BPU_H
#define BPU_H

#include "two_bit_counter.h"
#include "btb.h"
#include <vector>
#include <cstdint>
#include <cstddef>

/**
 * Branch Prediction Unit (BPU)
 * Combines 2-bit counters with Branch Target Buffer
 */
class BPU {
private:
    std::vector<TwoBitCounter> counters;
    BTB btb;
    size_t num_counters;
    size_t index_bits;
    size_t index_mask;
    
    // Statistics
    uint64_t predictions;
    uint64_t correct_predictions;
    uint64_t btb_hits;
    uint64_t btb_misses;
    
    // Get index from PC
    size_t get_index(uint32_t pc) const {
        return (pc >> 2) & index_mask;
    }

public:
    // Constructor
    explicit BPU(size_t num_counters = 1024, size_t btb_entries = 256)
        : counters(num_counters), btb(btb_entries), num_counters(num_counters),
          predictions(0), correct_predictions(0), btb_hits(0), btb_misses(0) {
        // Calculate index bits
        index_bits = 0;
        size_t n = num_counters;
        while (n > 1) {
            index_bits++;
            n >>= 1;
        }
        index_mask = (1 << index_bits) - 1;
    }
    
    // Make a prediction for a branch at given PC
    struct Prediction {
        bool taken;             // Predicted direction
        bool target_valid;      // Whether target is available
        uint32_t target;        // Predicted target address
    };
    
    Prediction predict(uint32_t pc) {
        Prediction pred;
        size_t index = get_index(pc);
        
        // Get direction prediction from 2-bit counter
        pred.taken = counters[index].predict();
        
        // Try to get target from BTB
        pred.target_valid = btb.lookup(pc, pred.target);
        
        return pred;
    }
    
    // Update BPU with actual outcome
    void update(uint32_t pc, bool actually_taken, uint32_t actual_target) {
        size_t index = get_index(pc);
        
        // Get prediction before update for statistics
        Prediction pred = predict(pc);
        
        // Update statistics
        predictions++;
        if (pred.taken == actually_taken) {
            correct_predictions++;
        }
        if (pred.target_valid) {
            btb_hits++;
        } else {
            btb_misses++;
        }
        
        // Update 2-bit counter
        counters[index].update(actually_taken);
        
        // Update BTB if branch was taken
        if (actually_taken) {
            btb.update(pc, actual_target);
        }
    }
    
    // Reset all counters and BTB
    void reset() {
        for (auto& counter : counters) {
            counter.reset();
        }
        btb.clear();
        predictions = 0;
        correct_predictions = 0;
        btb_hits = 0;
        btb_misses = 0;
    }
    
    // Get accuracy statistics
    double get_accuracy() const {
        return predictions > 0 ? 
            (double)correct_predictions / predictions : 0.0;
    }
    
    double get_btb_hit_rate() const {
        uint64_t total = btb_hits + btb_misses;
        return total > 0 ? (double)btb_hits / total : 0.0;
    }
    
    uint64_t get_predictions() const { return predictions; }
    uint64_t get_correct_predictions() const { return correct_predictions; }
    uint64_t get_btb_hits() const { return btb_hits; }
    uint64_t get_btb_misses() const { return btb_misses; }
};

#endif // BPU_H
