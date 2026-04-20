module debouncer #(
    parameter PULSE_COUNT_MAX = 10
)(
    input  logic clk,
    input  logic sample_pulse,   // from sample pulse generator
    input  logic sync_out,    // from synchronizer
    output logic switch_out
);

    // Clear signal when button is not pressed
    logic reset;
    assign reset = ~sync_out;

    // Enable counting only when sampling and input is HIGH
    logic enable;
    assign enable = sample_pulse & sync_out;

    // Correct counter width
    logic [$clog2(PULSE_COUNT_MAX+1)-1:0] count = 0;

    always_ff @(posedge clk) begin
        if (reset) begin
            count <= 0;
        end 
        else if (enable && (count < PULSE_COUNT_MAX)) begin
            count <= count + 1;
        end
    end

    always_ff @(posedge clk) begin
    switch_out <= (count == PULSE_COUNT_MAX);
    end

endmodule