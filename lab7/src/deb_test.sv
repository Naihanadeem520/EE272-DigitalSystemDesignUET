// ============================================================
// MODULE: deb_test
// PURPOSE: Testing module — lets you SEE debouncing on
//          an oscilloscope through PMOD pins
//
// WHY NO EDGE DETECTOR HERE?
//   Your mam wants you to observe the RAW debouncer output.
//   If edge detector was here, you'd only see a 1-cycle blink
//   which is too fast to see on an oscilloscope easily.
//
// INPUTS:
//   clk         = main FPGA clock
//   rst         = reset
//   glitchy_sig = switch[0] — switches also bounce!
//
// OUTPUTS (all go to PMOD pins → probe with oscilloscope):
//   CLK       = sample_pulse  → shows WHEN debouncer samples
//   ENABLE    = sample & sync → shows WHEN counter is counting
//   COUNT_SAT = debounced out → shows WHEN press is confirmed
// ============================================================

module deb_test #(
    parameter SAMPLE_COUNT_MAX = 50000,
    parameter PULSE_COUNT_MAX  = 10
)(
    input  logic clk,
    input  logic rst,
    input  logic glitchy_sig,   // switch[0] from a7top

    output logic CLK,           // PMOD pin A: sample timing pulse
    output logic ENABLE,        // PMOD pin B: counter is active
    output logic COUNT_SAT      // PMOD pin C: debounce confirmed
);

    // ── INTERNAL WIRES ──────────────────────────────────────
    logic sample_pulse;    // gen → debouncer + CLK pin
    logic sync_out_wire;   // sync → debouncer
    logic debounced_out;   // debouncer → COUNT_SAT pin

    // ── MODULE 1: SYNCHRONIZER ───────────────────────────────
    // glitchy_sig (noisy switch) → sync_out_wire (clean)
    synchronizer u_sync (
        .clk      (clk),
        .async_in (glitchy_sig),    // switch[0] from a7top
        .sync_out (sync_out_wire)
    );

    // ── MODULE 2: SAMPLE PULSE GENERATOR ─────────────────────
    // Creates timing heartbeat
    sample_pulse_gen #(
        .SAMPLE_COUNT_MAX(SAMPLE_COUNT_MAX)
    ) u_sample (
        .clk          (clk),
        .sample_pulse (sample_pulse)
    );

    // ── MODULE 3: DEBOUNCER ───────────────────────────────────
    debouncer #(
        .PULSE_COUNT_MAX(PULSE_COUNT_MAX)
    ) u_deb (
        .clk          (clk),
        .sample_pulse (sample_pulse),
        .sync_out     (sync_out_wire),
        .switch_out   (debounced_out)
    );

    // ── OSCILLOSCOPE PROBE OUTPUTS ───────────────────────────
    // These let you see THREE signals simultaneously:
    //
    //  CLK:       _|‾|___|‾|___|‾|___  (regular timing pulses)
    //  ENABLE:    _____|‾‾‾|___|‾‾‾|__ (HIGH when counting)
    //  COUNT_SAT: ___________|‾‾‾‾‾‾‾‾ (HIGH = stable press!)
    //
    assign CLK       = sample_pulse;              // timing reference
    assign ENABLE    = sample_pulse & sync_out_wire; // counting is happening
    assign COUNT_SAT = debounced_out;             // press confirmed

endmodule