`timescale 1ns / 1ps

module top_btn_parser_tb();

    // 1. Signals
    logic clk;
    logic rst;
    logic async_signal;

    logic edge_detect_pulse;
    logic sig_in;
    logic mod_clk;
    logic async_sig_out;

    // 2. Instantiate the Top Level Module
    // Small parameters for fast simulation:
    // Every 5 clocks = 1 sample pulse
    // 3 stable samples = confirmed press
    top_btn_parser #(
        .SAMPLE_COUNT_MAX(5), 
        .PULSE_COUNT_MAX(3)
    ) dut (
        .clk(clk),
        .rst(rst),
        .async_signal(async_signal),
        .edge_detect_pulse(edge_detect_pulse),
        .sig_in(sig_in),
        .mod_clk(mod_clk),
        .async_sig_out(async_sig_out)
    );

    // 3. Clock Generator (20ns period)
    initial clk = 0;
    always #10 clk = ~clk;

    // 4. Stimulus
    initial begin
        // Initialize
        rst = 1;
        async_signal = 0;
        #100;
        rst = 0;
        #20;

        // --- STEP 1: THE NOISY BOUNCE ---
        $display("Simulating a noisy button press...");
        async_signal = 1; #35;  // Hits sync, but too short for debounce
        async_signal = 0; #45;  
        async_signal = 1; #25;  
        async_signal = 0; #60;  // Debouncer should still be at 0

        // --- STEP 2: THE STABLE PRESS ---
        $display("Button is now held steady...");
        async_signal = 1; 
        
        // Wait long enough for 3 sample pulses to confirm the press
        #500; 

        // --- STEP 3: THE RELEASE ---
        $display("Button released.");
        async_signal = 0;
        #200;

        $display("Simulation complete.");
        $stop;
    end

endmodule
