module and_gate_tb;

logic a1;
logic b1;
logic y1;

localparam period = 10;

and_gate UUT (
    .A(a1),
    .B(b1),
    .Y(y1)
);

initial begin
    a1 = 0; b1 = 0;
    #period;
    a1 = 0; b1 = 1;
    #period;
    a1 = 1; b1 = 0;
    #period;
    a1 = 1; b1 = 1;
    #period;
    $stop;
end

initial begin
    $monitor("Y=%b A=%b B=%b", y1, a1, b1);
end

endmodule
