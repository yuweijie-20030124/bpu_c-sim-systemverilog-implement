/**
 * Testbench for Branch Target Buffer (BTB)
 */
module tb_btb;

    logic clk;
    logic rst_n;
    logic [31:0] lookup_pc;
    logic hit;
    logic [31:0] target;
    logic update_en;
    logic [31:0] update_pc;
    logic [31:0] update_target;
    
    // Instantiate DUT
    btb #(
        .INDEX_WIDTH(8),
        .ADDR_WIDTH(32)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .lookup_pc(lookup_pc),
        .hit(hit),
        .target(target),
        .update_en(update_en),
        .update_pc(update_pc),
        .update_target(update_target)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test sequence
    initial begin
        $display("Testing Branch Target Buffer");
        
        // Reset
        rst_n = 0;
        update_en = 0;
        lookup_pc = 0;
        update_pc = 0;
        update_target = 0;
        #20;
        rst_n = 1;
        #10;
        
        // Lookup non-existent entry
        lookup_pc = 32'h1000;
        #10;
        assert(hit == 0) else $error("Should miss on empty BTB");
        $display("  Lookup miss (empty BTB): hit=%b", hit);
        
        // Update BTB with entry
        update_en = 1;
        update_pc = 32'h1000;
        update_target = 32'h2000;
        #10;
        update_en = 0;
        #10;
        
        // Lookup should hit now
        lookup_pc = 32'h1000;
        #10;
        assert(hit == 1) else $error("Should hit after update");
        assert(target == 32'h2000) else $error("Target mismatch");
        $display("  Lookup hit: hit=%b, target=%h", hit, target);
        
        // Add another entry
        update_en = 1;
        update_pc = 32'h1004;
        update_target = 32'h3000;
        #10;
        update_en = 0;
        #10;
        
        // Lookup second entry
        lookup_pc = 32'h1004;
        #10;
        assert(hit == 1) else $error("Should hit second entry");
        assert(target == 32'h3000) else $error("Target mismatch for second entry");
        $display("  Lookup second entry: hit=%b, target=%h", hit, target);
        
        // Verify first entry still there
        lookup_pc = 32'h1000;
        #10;
        assert(hit == 1) else $error("First entry should still be there");
        assert(target == 32'h2000) else $error("First entry target mismatch");
        $display("  First entry still valid: hit=%b, target=%h", hit, target);
        
        $display("All tests PASSED");
        $finish;
    end

endmodule
