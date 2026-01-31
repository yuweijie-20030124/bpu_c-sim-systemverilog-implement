#ifndef TWO_BIT_COUNTER_H
#define TWO_BIT_COUNTER_H

#include <cstdint>

/**
 * 2-bit Saturating Counter for Branch Prediction
 * States: 00 (Strongly Not Taken), 01 (Weakly Not Taken),
 *         10 (Weakly Taken), 11 (Strongly Taken)
 */
class TwoBitCounter {
private:
    uint8_t counter;  // 2-bit counter value (0-3)

public:
    // Constructor - initialize to weakly taken (10)
    TwoBitCounter() : counter(2) {}
    
    // Initialize with specific value
    explicit TwoBitCounter(uint8_t init_val) : counter(init_val & 0x3) {}
    
    // Get prediction (true if counter >= 2, i.e., taken)
    bool predict() const {
        return counter >= 2;
    }
    
    // Update counter based on actual branch outcome
    void update(bool taken) {
        if (taken) {
            if (counter < 3) counter++;
        } else {
            if (counter > 0) counter--;
        }
    }
    
    // Get current counter value
    uint8_t get_value() const {
        return counter;
    }
    
    // Set counter value
    void set_value(uint8_t val) {
        counter = val & 0x3;
    }
    
    // Reset to default state
    void reset() {
        counter = 2;
    }
};

#endif // TWO_BIT_COUNTER_H
