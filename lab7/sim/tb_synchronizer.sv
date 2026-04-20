module tb_synchronizer();
logic clk;
logic async_in;
logic sync_out;

synchronizer uut(
    .clk(clk),
    .async_in(async_in),
    .sync_out(sync_out)
);
initial 
clk = 0;
always begin
    #10;
    clk = ~clk;
end
initial begin
    async_in=0;#45;
    async_in=1;#100;
    async_in=0;#100;
    $stop;
end
endmodule