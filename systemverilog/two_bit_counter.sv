/**
 * 2-bit Saturating Counter for Branch Prediction
 * States: 00 (Strongly Not Taken), 01 (Weakly Not Taken),
 *         10 (Weakly Taken), 11 (Strongly Taken)
 */
module two_bit_counter (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        update,      // Update enable signal
    input  logic        taken,       // Actual branch outcome
    output logic        prediction   // Predicted outcome (1 = taken)
);

    logic [1:0] counter;
    
    // Prediction logic: predict taken if counter >= 2
    assign prediction = counter[1];
    
    // Counter update logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 2'b10;  // Initialize to weakly taken
        end else if (update) begin
            if (taken) begin
                // Increment if not at maximum (saturate at 11)
                if (counter != 2'b11)
                    counter <= counter + 1'b1;
            end else begin
                // Decrement if not at minimum (saturate at 00)
                if (counter != 2'b00)
                    counter <= counter - 1'b1;
            end
        end
    end

endmodule
