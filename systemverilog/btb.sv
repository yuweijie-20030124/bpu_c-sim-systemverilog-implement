/**
 * Branch Target Buffer (BTB)
 * Stores mapping from branch PC to target address
 */
module btb #(
    parameter INDEX_WIDTH = 8,  // Number of index bits (256 entries default)
    parameter ADDR_WIDTH = 32   // Address width
) (
    input  logic                    clk,
    input  logic                    rst_n,
    
    // Lookup interface
    input  logic [ADDR_WIDTH-1:0]  lookup_pc,
    output logic                    hit,
    output logic [ADDR_WIDTH-1:0]  target,
    
    // Update interface
    input  logic                    update_en,
    input  logic [ADDR_WIDTH-1:0]  update_pc,
    input  logic [ADDR_WIDTH-1:0]  update_target
);

    localparam NUM_ENTRIES = 1 << INDEX_WIDTH;
    localparam TAG_WIDTH = ADDR_WIDTH - INDEX_WIDTH - 2;  // -2 for byte alignment
    
    // BTB storage - separate arrays for each field
    logic                    valid_array [NUM_ENTRIES-1:0];
    logic [TAG_WIDTH-1:0]    tag_array [NUM_ENTRIES-1:0];
    logic [ADDR_WIDTH-1:0]   target_array [NUM_ENTRIES-1:0];
    
    // Extract index and tag from PC
    function automatic logic [INDEX_WIDTH-1:0] get_index(logic [ADDR_WIDTH-1:0] pc);
        return pc[INDEX_WIDTH+1:2];
    endfunction
    
    function automatic logic [TAG_WIDTH-1:0] get_tag(logic [ADDR_WIDTH-1:0] pc);
        return pc[ADDR_WIDTH-1:INDEX_WIDTH+2];
    endfunction
    
    // Lookup logic (combinational)
    logic [INDEX_WIDTH-1:0] lookup_index;
    logic [TAG_WIDTH-1:0]   lookup_tag;
    
    assign lookup_index = get_index(lookup_pc);
    assign lookup_tag = get_tag(lookup_pc);
    
    assign hit = valid_array[lookup_index] && 
                 (tag_array[lookup_index] == lookup_tag);
    assign target = target_array[lookup_index];
    
    // Update logic (sequential)
    logic [INDEX_WIDTH-1:0] update_index;
    logic [TAG_WIDTH-1:0]   update_tag;
    
    assign update_index = get_index(update_pc);
    assign update_tag = get_tag(update_pc);
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < NUM_ENTRIES; i++) begin
                valid_array[i] <= 1'b0;
                tag_array[i] <= '0;
                target_array[i] <= '0;
            end
        end else if (update_en) begin
            valid_array[update_index] <= 1'b1;
            tag_array[update_index] <= update_tag;
            target_array[update_index] <= update_target;
        end
    end

endmodule
