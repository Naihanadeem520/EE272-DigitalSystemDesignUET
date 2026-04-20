module synchronizer (
    input  logic clk,
    input  logic async_in,
    output logic sync_out
);
    logic q1;

    always_ff @(posedge clk) begin
        q1 <= async_in;
        sync_out <= q1;
    end
endmodule
