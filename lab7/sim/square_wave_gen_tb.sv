`timescale 1ns / 1ps

module square_wave_gen_tb();

    // 1. Signals
    logic clk;
    logic rst;
    logic freq_up;
    logic sq_wave;

    // 2. Instantiate the Module
    square_wave_gen dut (
        .clk(clk),
        .rst(rst),
        .freq_up(freq_up),
        .sq_wave(sq_wave)
    );

    // 3. Clock Generator (20ns period)
    initial clk = 0;
    always #10 clk = ~clk;

    // 4. Stimulus
    initial begin
        // Initialize
        rst = 1;
        freq_up = 0;
        #100;
        rst = 0;

        // --- TEST 1: Default Frequency (freq_sel = 0) ---
        // period_max is 50000. To see this in simulation quickly, 
        // let's look at it for a few cycles.
        #1000; 

        // --- TEST 2: Change Frequency (Press Button) ---
        // This moves freq_sel from 0 to 1
        $display("Pressing freq_up: Changing to 2kHz setting...");
        @(posedge clk);
        freq_up = 1;
        @(posedge clk);
        freq_up = 0;
        
        #1000; // Observe the new frequency

        // --- TEST 3: Change Frequency Again ---
        // This moves freq_sel to 2
        $display("Pressing freq_up: Changing to 4kHz setting...");
        @(posedge clk);
        freq_up = 1;
        @(posedge clk);
        freq_up = 0;

        #1000;

        $display("Simulation complete.");
        $stop;
    end

endmodule
