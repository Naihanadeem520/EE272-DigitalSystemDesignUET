// ============================================================
// MODULE: pwm
// PURPOSE: Generates a PWM signal — output is HIGH for
//          (duty_cycle / MAX) fraction of each period
//
// HOW IT WORKS IN ONE SENTENCE:
//   A counter counts from 0 to MAX-1 forever.
//   Output = HIGH while counter < duty_cycle value.
//   Output = LOW  while counter >= duty_cycle value.
//
// PICTURE IN YOUR HEAD:
//   counter: 0,1,2,3,...,duty,...,MAX-1, 0,1,2,...
//   pwm_out: ‾‾‾‾‾‾‾‾‾‾‾_________‾‾‾‾‾‾‾‾‾‾‾_____
//
// INPUTS  (from a7top):
//   clk        = FPGA clock
//   rst        = reset everything to 0
//   duty_cycle = how many counts to stay HIGH
//                (comes from switches on the board)
//
// OUTPUT (to a7top → PMOD pin → oscilloscope/speaker):
//   pwm_out    = the actual PWM square wave
// ============================================================

module pwm #(
    // PERIOD_MAX = total number of clock cycles per PWM period
    // Example: 50MHz clock, PERIOD_MAX=1000 → PWM runs at 50kHz
    // Example: 50MHz clock, PERIOD_MAX=50000 → PWM runs at 1kHz
    parameter PERIOD_MAX = 1024  // 1024 gives us 10-bit resolution
)(
    input  logic clk,
    input  logic rst,

    // duty_cycle sets HOW LONG output stays HIGH each period
    // Range: 0 (always OFF) to PERIOD_MAX (always ON)
    // Width: needs enough bits to hold value up to PERIOD_MAX
    input  logic [$clog2(PERIOD_MAX)-1:0] duty_cycle,

    output logic pwm_out
);

    // ── THE COUNTER ──────────────────────────────────────────
    // This is the "wrapping counter" — same idea as sample_pulse_gen
    // It counts 0, 1, 2, 3 ... PERIOD_MAX-1, then wraps to 0
    // $clog2(PERIOD_MAX) gives us exactly enough bits
    // e.g. PERIOD_MAX=1024 → $clog2(1024)=10 → 10-bit counter
    logic [$clog2(PERIOD_MAX)-1:0] count;

    always_ff @(posedge clk) begin
        if (rst) begin
            // Reset: go back to zero immediately
            count <= 0;
        end
        else if (count == PERIOD_MAX - 1) begin
            // Counter reached the top — wrap back to 0
            // This is what makes it repeat forever (PWM is periodic)
            count <= 0;
        end
        else begin
            // Normal counting: just keep incrementing
            count <= count + 1;
        end
    end

    // ── THE COMPARATOR ───────────────────────────────────────
    // This is the heart of PWM — one single comparison
    // "Is the counter LESS THAN the duty cycle value?"
    //   YES → output HIGH (we are in the ON part of the period)
    //   NO  → output LOW  (we are in the OFF part of the period)
    //
    // Example: PERIOD_MAX=1000, duty_cycle=300
    //   count 0-299   → pwm_out = 1  (300 cycles = 30% of period)
    //   count 300-999 → pwm_out = 0  (700 cycles = 70% of period)
    //   Result: 30% duty cycle
    //
    // This is a COMBINATIONAL assignment (no clock needed)
    // because it just needs to compare two numbers instantly
    assign pwm_out = (count < duty_cycle);

endmodule