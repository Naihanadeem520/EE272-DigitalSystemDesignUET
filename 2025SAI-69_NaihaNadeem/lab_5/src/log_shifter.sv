module log_shifter (
    input  logic [3:0] x,
    input  logic [1:0] s,
    input  logic zero_en,
    output logic [3:0] y
);
    logic [3:0] stage1, stage2;

    // Stage 1: Shift by 2 (controlled by s[1])
    mux2to1 m0 (.sel(s[1]), .d0(x[0]), .d1(1'b0), .y(stage1[0])); // No shift
    mux2to1 m1 (.sel(s[1]), .d0(x[1]), .d1(1'b0), .y(stage1[1])); // No shift
    mux2to1 m2 (.sel(s[1]), .d0(x[2]), .d1(x[0]), .y(stage1[2])); // Shifted
    mux2to1 m3 (.sel(s[1]), .d0(x[3]), .d1(x[1]), .y(stage1[3])); // Shifted

    // Stage 2: Shift by 1 (controlled by s[0])
    mux2to1 m4 (.sel(s[0]), .d0(stage1[0]), .d1(1'b0),     .y(stage2[0]));
    mux2to1 m5 (.sel(s[0]), .d0(stage1[1]), .d1(stage1[0]), .y(stage2[1]));
    mux2to1 m6 (.sel(s[0]), .d0(stage1[2]), .d1(stage1[1]), .y(stage2[2]));
    mux2to1 m7 (.sel(s[0]), .d0(stage1[3]), .d1(stage1[2]), .y(stage2[3]));

    assign y = (zero_en) ? 4'b0000 : stage2;
endmodule


