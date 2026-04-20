`timescale 1ns / 1ps

module debouncer_tb();

    // 1. Signals
    logic clk;
    logic sample_pulse;
    logic sync_out;
    logic switch_out;

    // 2. Instantiate the Debouncer
    // We set PULSE_COUNT_MAX to 5 so we don't have to wait too long
    debouncer #(
        .PULSE_COUNT_MAX(5) 
    ) dut (
        .clk(clk),
        .sample_pulse(sample_pulse),
        .sync_out(sync_out),
        .switch_out(switch_out)
    );

    // 3. Clock Generator (20ns period)
    initial clk = 0;
    always #10 clk = ~clk;

    // 4. Sample Pulse Generator (Heartbeat)
    // Create a pulse every 40ns (every 2 clock cycles)
    initial sample_pulse = 0;
    always begin
        #30; sample_pulse = 1;
        #20; sample_pulse = 0;
        #30; // total 80ns cycle for demo purposes
    end

    // 5. The "Bouncy Button" Stimulus
    initial begin
        sync_out = 0;
        #100;

        // --- PHASE 1: THE BOUNCE (Flickering) ---
        $display("Button starts bouncing...");
        sync_out = 1; #30;  // Quick press
        sync_out = 0; #40;  // Quick release
        sync_out = 1; #20;  // Quick press
        sync_out = 0; #50;  // Quick release (Counter should keep resetting to 0)

        // --- PHASE 2: THE STEADY PRESS ---
        $display("Button held down steadily...");
        sync_out = 1; 
        
        // Wait long enough for 5 sample pulses to occur
        #1000; 

        // --- PHASE 3: RELEASE ---
        sync_out = 0;
        #200;

        $display("Simulation complete.");
        $stop;
    end

endmodule
