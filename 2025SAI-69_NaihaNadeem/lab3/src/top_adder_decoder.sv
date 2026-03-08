module top_adder_decoder(
    input  logic [2:0] a,
    input  logic [2:0] b,
    input  logic       c_in,
    input  logic [2:0] sel,
    output logic [6:0] seg,
    output logic [7:0] an
);

logic [2:0] sum;
logic cout;
logic [3:0] result;

ripple_carry RCA (
    .a(a),
    .b(b),
    .cin(c_in),
    .sum(sum),
    .cout(cout)
);

assign result = {cout, sum};

hex7seg_decoder HEX (
    .dec(result),
    .seg(seg)
);

anode_decoder AN (
    .sel(sel),
    .AN(an)
);

endmodule