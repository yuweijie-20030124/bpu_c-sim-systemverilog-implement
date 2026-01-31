/**
 * Testbench for Branch Prediction Unit (BPU)
 */
module tb_bpu;

    logic clk;
    logic rst_n;
    logic [31:0] pred_pc;
    logic pred_taken;
    logic pred_target_valid;
    logic [31:0] pred_target;
    logic update_en;
    logic [31:0] update_pc;
    logic update_taken;
    logic [31:0] update_target;
    
    // Instantiate DUT
    bpu #(
        .COUNTER_INDEX_WIDTH(10),
        .BTB_INDEX_WIDTH(8),
        .ADDR_WIDTH(32)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .pred_pc(pred_pc),
        .pred_taken(pred_taken),
        .pred_target_valid(pred_target_valid),
        .pred_target(pred_target),
        .update_en(update_en),
        .update_pc(update_pc),
        .update_taken(update_taken),
        .update_target(update_target)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test sequence
    initial begin
        $display("Testing Branch Prediction Unit");
        
        // Reset
        rst_n = 0;
        update_en = 0;
        pred_pc = 0;
        update_pc = 0;
        update_taken = 0;
        update_target = 0;
        #20;
        rst_n = 1;
        #10;
        
        // Make initial prediction for PC 0x1000
        pred_pc = 32'h1000;
        #10;
        $display("  Initial prediction: taken=%b, target_valid=%b", 
                 pred_taken, pred_target_valid);
        assert(pred_taken == 1) else $error("Initial prediction should be taken");
        assert(pred_target_valid == 0) else $error("BTB should be empty initially");
        
        // Update with taken branch
        update_en = 1;
        update_pc = 32'h1000;
        update_taken = 1;
        update_target = 32'h2000;
        #10;
        update_en = 0;
        #10;
        
        // Predict again - should have BTB entry now
        pred_pc = 32'h1000;
        #10;
        $display("  After update: taken=%b, target_valid=%b, target=%h", 
                 pred_taken, pred_target_valid, pred_target);
        assert(pred_taken == 1) else $error("Should predict taken");
        assert(pred_target_valid == 1) else $error("BTB should have entry");
        assert(pred_target == 32'h2000) else $error("Target mismatch");
        
        // Train counter to not taken (need 3 updates)
        update_en = 1;
        update_pc = 32'h1000;
        update_taken = 0;
        update_target = 0;
        #10; #10; #10;  // 3 cycles
        update_en = 0;
        #10;
        
        // Should predict not taken now
        pred_pc = 32'h1000;
        #10;
        $display("  After training not taken: taken=%b", pred_taken);
        assert(pred_taken == 0) else $error("Should predict not taken after training");
        
        // Test with different PC
        pred_pc = 32'h1004;
        #10;
        $display("  Different PC prediction: taken=%b, target_valid=%b", 
                 pred_taken, pred_target_valid);
        assert(pred_taken == 1) else $error("New PC should predict taken");
        assert(pred_target_valid == 0) else $error("New PC should have no BTB entry");
        
        $display("All tests PASSED");
        $finish;
    end

endmodule
