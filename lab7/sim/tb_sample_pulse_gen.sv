module tb_sample_pulse_gen();
logic clk;
logic sample_pulse;

sample_pulse_gen #(
    .SAMPLE_COUNT_MAX(10)
)
dut(
    .clk(clk),
    .sample_pulse(sample_pulse)

);
initial clk=0;
always begin
    #10;
    clk = ~clk;
end
initial begin
    #300;
    $stop;
end
endmodule