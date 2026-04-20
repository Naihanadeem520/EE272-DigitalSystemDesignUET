// Detects rising edge of debounced signal
// Output pulse is 1 clock cycle wide on each rising edge
module edge_detector (
    input  logic clk,
    input  logic  switch_out,
    output logic edge_pulse
);
    logic sig_out;

    always_ff @(posedge clk) begin
        sig_out   <= switch_out;
        edge_pulse <= switch_out & ~sig_out;  // HIGH only on rising edge
    end
endmodule