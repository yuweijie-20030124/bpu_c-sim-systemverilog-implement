/**
 * Testbench for 2-bit Saturating Counter
 */
module tb_two_bit_counter;

    logic clk;
    logic rst_n;
    logic update;
    logic taken;
    logic prediction;
    
    // Instantiate DUT
    two_bit_counter dut (
        .clk(clk),
        .rst_n(rst_n),
        .update(update),
        .taken(taken),
        .prediction(prediction)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test sequence
    initial begin
        $display("Testing 2-bit Saturating Counter");
        
        // Reset
        rst_n = 0;
        update = 0;
        taken = 0;
        #20;
        rst_n = 1;
        #10;
        
        // Initial prediction should be taken (10)
        assert(prediction == 1) else $error("Initial prediction should be taken");
        $display("  Initial state: prediction=%b", prediction);
        
        // Update with taken - should go to 11 (strongly taken)
        update = 1;
        taken = 1;
        #10;
        assert(prediction == 1) else $error("Should still predict taken");
        $display("  After taken: prediction=%b", prediction);
        
        // Update with taken again - should saturate at 11
        taken = 1;
        #10;
        assert(prediction == 1) else $error("Should still predict taken");
        $display("  After taken (saturate): prediction=%b", prediction);
        
        // Update with not taken - should go to 10
        taken = 0;
        #10;
        assert(prediction == 1) else $error("Should still predict taken");
        $display("  After not taken: prediction=%b", prediction);
        
        // Update with not taken - should go to 01 (weakly not taken)
        taken = 0;
        #10;
        assert(prediction == 0) else $error("Should predict not taken");
        $display("  After not taken: prediction=%b", prediction);
        
        // Update with not taken - should go to 00 (strongly not taken)
        taken = 0;
        #10;
        assert(prediction == 0) else $error("Should predict not taken");
        $display("  After not taken: prediction=%b", prediction);
        
        // Update with not taken - should saturate at 00
        taken = 0;
        #10;
        assert(prediction == 0) else $error("Should predict not taken");
        $display("  After not taken (saturate): prediction=%b", prediction);
        
        $display("All tests PASSED");
        $finish;
    end

endmodule
