`timescale 1ns / 1ps

module pwm_tb();

    // 1. Signals
    logic clk;
    logic rst;
    logic [3:0] duty_cycle; // 4 bits can hold the value 10
    logic pwm_out;

    // 2. Instantiate PWM with a small period for easy viewing
    pwm #(
        .PERIOD_MAX(10) 
    ) dut (
        .clk(clk),
        .rst(rst),
        .duty_cycle(duty_cycle),
        .pwm_out(pwm_out)
    );

    // 3. Clock Generator (20ns period)
    initial clk = 0;
    always #10 clk = ~clk;

    // 4. Stimulus
    initial begin
        // Initialize
        rst = 1;
        duty_cycle = 0;
        #100;
        rst = 0;

        // --- TEST 1: 30% Duty Cycle ---
        $display("Setting Duty Cycle to 3 (30%)");
        duty_cycle = 3;
        #400; // Let it run for 2 full periods (100ns per period)

        // --- TEST 2: 80% Duty Cycle ---
        $display("Setting Duty Cycle to 8 (80%)");
        duty_cycle = 8;
        #400;

        // --- TEST 3: 0% and 100% ---
        $display("Testing 0% (Always Low)");
        duty_cycle = 0;
        #200;
        
        $display("Testing 100% (Always High)");
        duty_cycle = 10;
        #200;

        $display("Simulation complete.");
        $stop;
    end

endmodule
