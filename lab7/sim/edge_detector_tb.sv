`timescale 1ns / 1ps

module edge_detector_tb();

    // 1. Signals
    logic clk;
    logic switch_out;
    logic edge_pulse;

    // 2. Instantiate the Module
    edge_detector dut (
        .clk(clk),
        .switch_out(switch_out),
        .edge_pulse(edge_pulse)
    );

    // 3. Clock Generator (20ns period)
    initial clk = 0;
    always #10 clk = ~clk;

    // 4. Stimulus
    initial begin
        // Initialize
        switch_out = 0;
        #100;

        // --- TEST 1: A Long Press ---
        $display("Simulating a long button press...");
        switch_out = 1;      // Button pressed and HELD
        #200;                // Hold for 10 clock cycles
        
        // --- TEST 2: Release ---
        switch_out = 0;      // Button released
        #100;

        // --- TEST 3: Multiple Fast Presses ---
        $display("Simulating fast clicks...");
        switch_out = 1; #40;
        switch_out = 0; #40;
        switch_out = 1; #40;
        switch_out = 0; #100;

        $display("Simulation complete.");
        $stop;
    end

endmodule
