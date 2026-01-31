#ifndef BTB_H
#define BTB_H

#include <cstdint>
#include <cstddef>
#include <vector>

/**
 * Branch Target Buffer (BTB)
 * Stores mapping from branch PC to target address
 */
class BTB {
private:
    struct BTBEntry {
        uint32_t tag;           // Tag for the branch PC
        uint32_t target;        // Target address
        bool valid;             // Valid bit
        
        BTBEntry() : tag(0), target(0), valid(false) {}
    };
    
    std::vector<BTBEntry> entries;
    size_t num_entries;
    size_t index_bits;
    size_t index_mask;
    
    // Get index from PC
    size_t get_index(uint32_t pc) const {
        return (pc >> 2) & index_mask;  // Shift by 2 assuming 4-byte aligned
    }
    
    // Get tag from PC
    uint32_t get_tag(uint32_t pc) const {
        return pc >> (2 + index_bits);
    }

public:
    // Constructor - create BTB with specified number of entries (must be power of 2)
    explicit BTB(size_t num_entries = 256) 
        : entries(num_entries), num_entries(num_entries) {
        // Calculate index bits
        index_bits = 0;
        size_t n = num_entries;
        while (n > 1) {
            index_bits++;
            n >>= 1;
        }
        index_mask = (1 << index_bits) - 1;
    }
    
    // Lookup target address for a given PC
    bool lookup(uint32_t pc, uint32_t& target) const {
        size_t index = get_index(pc);
        uint32_t tag = get_tag(pc);
        
        const BTBEntry& entry = entries[index];
        if (entry.valid && entry.tag == tag) {
            target = entry.target;
            return true;
        }
        return false;
    }
    
    // Update BTB with new branch PC and target
    void update(uint32_t pc, uint32_t target) {
        size_t index = get_index(pc);
        uint32_t tag = get_tag(pc);
        
        BTBEntry& entry = entries[index];
        entry.tag = tag;
        entry.target = target;
        entry.valid = true;
    }
    
    // Invalidate an entry
    void invalidate(uint32_t pc) {
        size_t index = get_index(pc);
        entries[index].valid = false;
    }
    
    // Clear all entries
    void clear() {
        for (auto& entry : entries) {
            entry.valid = false;
        }
    }
    
    // Get number of entries
    size_t size() const {
        return num_entries;
    }
};

#endif // BTB_H
