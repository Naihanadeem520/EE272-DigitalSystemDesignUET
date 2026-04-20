// ============================================================
// MODULE: square_wave_gen
// PURPOSE: Generates a square wave (always 50% duty cycle)
//          but with ADJUSTABLE FREQUENCY using button presses
//
// HOW IT RELATES TO PWM:
//   PWM:        fixed frequency, variable duty cycle
//   Square wave: variable frequency, FIXED 50% duty cycle
//
// HOW FREQUENCY CONTROL WORKS:
//   edge_pulse from your button parser → increments period_sel
//   period_sel picks a different PERIOD_MAX from a lookup table
//   Bigger PERIOD_MAX = slower frequency = lower pitch sound
//
// INPUTS (from a7top):
//   clk        = FPGA clock
//   rst        = reset
//   freq_up    = edge_pulse from your top_btn_parser
//                (each button press = go to next frequency)
//
// OUTPUT (to PMOD pin → speaker or oscilloscope):
//   sq_wave    = 50% duty square wave at selected frequency
// ============================================================

module square_wave_gen (
    input  logic clk,
    input  logic rst,
    input  logic freq_up,   // 1-cycle pulse from edge detector

    output logic sq_wave
);

    // ── FREQUENCY LOOKUP TABLE ───────────────────────────────
    // We pre-define several period values, each giving a
    // different frequency. Button press steps through them.
    //
    // Formula: frequency = 50_000_000 / PERIOD_MAX
    //
    //   PERIOD_MAX = 50000  → 50MHz / 50000  = 1000 Hz (1kHz)
    //   PERIOD_MAX = 100000 → 50MHz / 100000 = 500  Hz
    //   PERIOD_MAX = 25000  → 50MHz / 25000  = 2000 Hz (2kHz)
    //   PERIOD_MAX = 12500  → 50MHz / 12500  = 4000 Hz (4kHz)

    // 4 frequency choices, so we need a 2-bit selector (0,1,2,3)
    logic [1:0] freq_sel;

    // period_max holds the currently selected PERIOD_MAX value
    // 32 bits to hold large numbers like 100000
    logic [31:0] period_max;

    // Lookup table: translate freq_sel → period_max
    // This is a combinational always block (always_comb)
    // = no clock, just instant logic like a truth table
    always_comb begin
        case (freq_sel)
            2'd0: period_max = 32'd50000;   // 1kHz
            2'd1: period_max = 32'd25000;   // 2kHz
            2'd2: period_max = 32'd12500;   // 4kHz
            2'd3: period_max = 32'd6250;    // 8kHz
            default: period_max = 32'd50000;
        endcase
    end

    // ── FREQUENCY SELECTOR COUNTER ───────────────────────────
    // Each time freq_up pulses HIGH (one button press),
    // increment freq_sel. It wraps: 0→1→2→3→0→1...
    always_ff @(posedge clk) begin
        if (rst) begin
            freq_sel <= 0;   // start at frequency 0 (1kHz)
        end
        else if (freq_up) begin
            // freq_sel is 2-bit so it wraps automatically at 4
            // 2'b11 + 1 = 2'b00 (overflow = free wrap-around)
            freq_sel <= freq_sel + 1;
        end
    end

    // ── THE ACTUAL COUNTER (same idea as PWM counter) ────────
    logic [31:0] count;

    always_ff @(posedge clk) begin
        if (rst) begin
            count <= 0;
        end
        else if (count >= period_max - 1) begin
            // Wrap when we reach the selected period
            count <= 0;
        end
        else begin
            count <= count + 1;
        end
    end

    // ── 50% DUTY CYCLE COMPARATOR ────────────────────────────
    // Square wave = HIGH for first half of period, LOW for second
    // "Is count less than HALF the period?"
    //   count < period_max/2  → HIGH (first half)
    //   count >= period_max/2 → LOW  (second half)
    //
    // period_max >> 1 means "divide by 2" using bit shift
    // This is faster than actual division in hardware
    assign sq_wave = (count < (period_max >> 1));

endmodule