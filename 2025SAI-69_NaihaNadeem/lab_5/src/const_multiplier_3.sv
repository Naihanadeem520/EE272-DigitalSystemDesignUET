module multiplier (
    input  logic [3:0] x,
    output logic [3:0] p
);
    logic [3:0] s0_out; // X shifted by 0
    logic [3:0] s1_out; // X shifted by 1
    logic cout_unused;

    // Shifter 0: Shift by 0 (s=2'b00) -> Output is X
    log_shifter shifter0 (
        .x(x), .s(2'b00), .zero_en(1'b0), .y(s0_out)
    );

    // Shifter 1: Shift by 1 (s=2'b01) -> Output is 2X
    log_shifter shifter1 (
        .x(x), .s(2'b01), .zero_en(1'b0), .y(s1_out)
    );

    // Adder: P = X + 2X
    ripple_adder adder_inst (
        .a(s0_out), .b(s1_out), .cin(1'b0), 
        .sum(p), .cout(cout_unused)
    );
endmodule
