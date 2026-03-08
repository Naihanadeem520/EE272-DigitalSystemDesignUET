module anode_decoder(
    input  [2:0] sel,
    output [7:0] AN
);

assign AN[0] = ~(~sel[2] & ~sel[1] & ~sel[0]);
assign AN[1] = ~(~sel[2] & ~sel[1] &  sel[0]);
assign AN[2] = ~(~sel[2] &  sel[1] & ~sel[0]);
assign AN[3] = ~(~sel[2] &  sel[1] &  sel[0]);
assign AN[4] = ~( sel[2] & ~sel[1] & ~sel[0]);
assign AN[5] = ~( sel[2] & ~sel[1] &  sel[0]);
assign AN[6] = ~( sel[2] &  sel[1] & ~sel[0]);
assign AN[7] = ~( sel[2] &  sel[1] &  sel[0]);

endmodule