module decoder_tb;

logic [2:0] a;
logic [2:0] b;
logic       c_in;
logic [2:0] sel;

logic [6:0] seg;
logic [7:0] an;

top_adder_decoder MEA (
    .a(a),
    .b(b),
    .c_in(c_in),
    .sel(sel),
    .seg(seg),
    .an(an)
);

initial begin

    $display("a\tb\tc_in\tseg\tan");

    a = 3;
    b = 4;
    c_in = 0;
    sel = 3'd7;
    #10;

    $display("%b\t%b\t%b\t%b\t%b", a, b, c_in , seg , an);

    if (seg != 7'b0001111)
        $display("ERROR: seg_output_incorrect");
    else
        $display("PASS: seg_output_correct");

    if (an != 8'b01111111)
        $display("ERROR: an_output_incorrect");
    else
        $display("PASS: an_output_correct");

    $stop;

end

endmodule