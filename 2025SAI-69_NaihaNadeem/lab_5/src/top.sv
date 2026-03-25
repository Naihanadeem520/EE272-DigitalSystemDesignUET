module top_module (
    input  logic [3:0] x,       // Input number (Switches 0-3)
    input  logic [2:0] sel,     // Anode select (Switches 4-6)
    output logic [6:0] seg,     // 7-segment segments
    output logic [7:0] an       // 7-segment anodes
);

    // Internal signal to hold the product
    logic [3:0] p;

    // Calculate 3 * X
    multiplier mult_inst (.x(x), .p(p));

    // Convert Product to 7-segment code
    seven_seg_decoder ssd_inst (.bin(p), .seg(seg));

    // Select which digit to turn on
    decoder_sel an_inst (.sel(sel), .an(an));

endmodule