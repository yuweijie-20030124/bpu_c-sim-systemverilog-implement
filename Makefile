# Makefile for BPU C++ Simulation and SystemVerilog Implementation

# C++ compiler settings
CXX = g++
CXXFLAGS = -std=c++11 -Wall -Wextra -O2

# Directories
CPP_DIR = cpp_sim
SV_DIR = systemverilog
TEST_DIR = tests
BUILD_DIR = build

# C++ test executable
CPP_TEST = $(BUILD_DIR)/test_bpu

# SystemVerilog simulator (using iverilog by default)
SV_COMPILER = iverilog
SV_SIMULATOR = vvp
SV_FLAGS = -g2012 -Wall

# Targets
.PHONY: all clean test test-cpp test-sv help

all: test

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Build C++ test
$(CPP_TEST): $(TEST_DIR)/test_bpu.cpp $(CPP_DIR)/*.h | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -I. $< -o $@

# Test C++ implementation
test-cpp: $(CPP_TEST)
	@echo "========================================"
	@echo "Running C++ Tests"
	@echo "========================================"
	./$(CPP_TEST)

# Test SystemVerilog two_bit_counter
test-sv-counter: | $(BUILD_DIR)
	@echo "========================================"
	@echo "Testing SystemVerilog 2-bit Counter"
	@echo "========================================"
	$(SV_COMPILER) $(SV_FLAGS) -o $(BUILD_DIR)/tb_two_bit_counter.vvp \
		$(SV_DIR)/two_bit_counter.sv $(TEST_DIR)/tb_two_bit_counter.sv
	$(SV_SIMULATOR) $(BUILD_DIR)/tb_two_bit_counter.vvp

# Test SystemVerilog BTB
test-sv-btb: | $(BUILD_DIR)
	@echo "========================================"
	@echo "Testing SystemVerilog BTB"
	@echo "========================================"
	$(SV_COMPILER) $(SV_FLAGS) -o $(BUILD_DIR)/tb_btb.vvp \
		$(SV_DIR)/btb.sv $(TEST_DIR)/tb_btb.sv
	$(SV_SIMULATOR) $(BUILD_DIR)/tb_btb.vvp

# Test SystemVerilog BPU
test-sv-bpu: | $(BUILD_DIR)
	@echo "========================================"
	@echo "Testing SystemVerilog BPU"
	@echo "========================================"
	$(SV_COMPILER) $(SV_FLAGS) -o $(BUILD_DIR)/tb_bpu.vvp \
		$(SV_DIR)/two_bit_counter.sv $(SV_DIR)/btb.sv $(SV_DIR)/bpu.sv \
		$(TEST_DIR)/tb_bpu.sv
	$(SV_SIMULATOR) $(BUILD_DIR)/tb_bpu.vvp

# Test all SystemVerilog modules
test-sv: test-sv-counter test-sv-btb test-sv-bpu

# Run all tests
test: test-cpp test-sv
	@echo ""
	@echo "========================================"
	@echo "All Tests Completed Successfully!"
	@echo "========================================"

# Clean build artifacts
clean:
	rm -rf $(BUILD_DIR)
	rm -f *.vcd *.vvp

# Help target
help:
	@echo "BPU Build System"
	@echo "=================="
	@echo ""
	@echo "Targets:"
	@echo "  all           - Run all tests (default)"
	@echo "  test          - Run all tests"
	@echo "  test-cpp      - Run C++ tests only"
	@echo "  test-sv       - Run SystemVerilog tests only"
	@echo "  test-sv-counter - Test 2-bit counter module"
	@echo "  test-sv-btb   - Test BTB module"
	@echo "  test-sv-bpu   - Test BPU module"
	@echo "  clean         - Remove build artifacts"
	@echo "  help          - Show this help message"
