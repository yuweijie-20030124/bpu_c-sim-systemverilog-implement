/**
 * Branch Prediction Unit (BPU)
 * Combines 2-bit counters with Branch Target Buffer
 */
module bpu #(
    parameter COUNTER_INDEX_WIDTH = 10,  // 1024 counters default
    parameter BTB_INDEX_WIDTH = 8,       // 256 BTB entries default
    parameter ADDR_WIDTH = 32
) (
    input  logic                    clk,
    input  logic                    rst_n,
    
    // Prediction interface
    input  logic [ADDR_WIDTH-1:0]  pred_pc,
    output logic                    pred_taken,
    output logic                    pred_target_valid,
    output logic [ADDR_WIDTH-1:0]  pred_target,
    
    // Update interface
    input  logic                    update_en,
    input  logic [ADDR_WIDTH-1:0]  update_pc,
    input  logic                    update_taken,
    input  logic [ADDR_WIDTH-1:0]  update_target
);

    localparam NUM_COUNTERS = 1 << COUNTER_INDEX_WIDTH;
    
    // Counter array
    logic [1:0] counter_array [NUM_COUNTERS-1:0];
    
    // Extract counter index from PC
    function automatic logic [COUNTER_INDEX_WIDTH-1:0] get_counter_index(
        logic [ADDR_WIDTH-1:0] pc
    );
        return pc[COUNTER_INDEX_WIDTH+1:2];
    endfunction
    
    // Prediction logic
    logic [COUNTER_INDEX_WIDTH-1:0] pred_index;
    assign pred_index = get_counter_index(pred_pc);
    assign pred_taken = counter_array[pred_index][1];  // Predict taken if counter >= 2
    
    // BTB instance
    btb #(
        .INDEX_WIDTH(BTB_INDEX_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) btb_inst (
        .clk(clk),
        .rst_n(rst_n),
        .lookup_pc(pred_pc),
        .hit(pred_target_valid),
        .target(pred_target),
        .update_en(update_en && update_taken),  // Only update BTB when branch is taken
        .update_pc(update_pc),
        .update_target(update_target)
    );
    
    // Counter update logic
    logic [COUNTER_INDEX_WIDTH-1:0] update_index;
    assign update_index = get_counter_index(update_pc);
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < NUM_COUNTERS; i++) begin
                counter_array[i] <= 2'b10;  // Initialize to weakly taken
            end
        end else if (update_en) begin
            if (update_taken) begin
                // Increment if not at maximum (saturate at 11)
                if (counter_array[update_index] != 2'b11)
                    counter_array[update_index] <= counter_array[update_index] + 1'b1;
            end else begin
                // Decrement if not at minimum (saturate at 00)
                if (counter_array[update_index] != 2'b00)
                    counter_array[update_index] <= counter_array[update_index] - 1'b1;
            end
        end
    end

endmodule
