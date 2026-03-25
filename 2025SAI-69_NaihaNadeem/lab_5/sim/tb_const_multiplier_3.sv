module tb_multiplier;
    logic [3:0] x;
    logic [2:0] sel;
    logic [3:0] p;
    logic [6:0] seg;
    logic [7:0] an;

    top_module uut (.*); // Connects all signals by name

    initial begin
        sel = 3'b000; // Display on the first digit
        $display("Simulating: X * 3 = P");
        
        for (int i = 0; i < 16; i++) begin
            x = i;
            #10; // Wait 10ns between steps
        end
        
        $finish;
    end
endmodule
