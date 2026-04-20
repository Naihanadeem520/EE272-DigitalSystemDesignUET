// ============================================================
// MODULE: top_btn_parser
// PURPOSE: Chains all your sub-modules into one clean pipeline
//
// SIGNAL FLOW:
//   async_signal → synchronizer → debouncer → edge_detector
//                                    ↑
//                          sample_pulse_gen
//
// INPUTS that cross the boundary from OUTSIDE:
//   clk           = main FPGA clock
//   rst           = reset (push_button[0] from a7top)
//   async_signal  = raw bouncy button (push_button[1] from a7top)
//
// OUTPUTS that cross the boundary to OUTSIDE:
//   edge_detect_pulse = single 1-cycle pulse per button press
//   sig_in            = DEBUG: what signal looks like after sync
//   mod_clk           = DEBUG: sample timing pulse (oscilloscope)
//   async_sig_out     = DEBUG: raw button before any processing
// ============================================================

module top_btn_parser #(
    parameter SAMPLE_COUNT_MAX = 50000, // 50MHz ÷ 50000 = 1ms per sample
    parameter PULSE_COUNT_MAX  = 10     // 10 stable samples = confirmed press
)(
    input  logic clk,
    input  logic rst,
    input  logic async_signal,

    output logic edge_detect_pulse,
    output logic sig_in,
    output logic mod_clk,
    output logic async_sig_out
);

    // ── INTERNAL WIRES ──────────────────────────────────────
    // These are arrows BETWEEN boxes in the diagram
    // They do NOT appear as ports because they stay inside
    logic sample_pulse;   // sample_gen → debouncer enable
    logic sync_out_wire;  // synchronizer → debouncer
    logic debounced_out;  // debouncer → edge_detector

    // ── DEBUG ASSIGNMENTS ────────────────────────────────────
    // Your mam connects these to PMOD pins in a7top
    // so you can probe them with an oscilloscope
    assign async_sig_out = async_signal;   // raw signal BEFORE any processing
    assign sig_in        = sync_out_wire;  // signal AFTER synchronizer
    assign mod_clk       = sample_pulse;   // the timing heartbeat pulse

    // ── MODULE 1: SYNCHRONIZER ───────────────────────────────
    // Diagram: bottom-left box
    // async_signal (bouncy/async) → sync_out_wire (clean/synchronous)
    synchronizer u_sync (
        .clk      (clk),
        .async_in (async_signal),   // arrow IN from boundary
        .sync_out (sync_out_wire)   // arrow OUT to debouncer
    );

    // ── MODULE 2: SAMPLE PULSE GENERATOR ─────────────────────
    // Diagram: top-left box
    // Produces a short HIGH pulse every SAMPLE_COUNT_MAX cycles
    // This is the "heartbeat" — tells debouncer WHEN to check
    sample_pulse_gen #(
        .SAMPLE_COUNT_MAX(SAMPLE_COUNT_MAX)
    ) u_sample (
        .clk          (clk),
        .sample_pulse (sample_pulse)  // arrow OUT to debouncer enable
    );

    // ── MODULE 3: DEBOUNCER ───────────────────────────────────
    // Diagram: middle box (saturating counter)
    // Counts stable HIGH samples — only outputs 1 after
    // PULSE_COUNT_MAX consecutive confirmed samples
    debouncer #(
        .PULSE_COUNT_MAX(PULSE_COUNT_MAX)
    ) u_deb (
        .clk          (clk),
        .sample_pulse (sample_pulse),   // Enable: check on this pulse
        .sync_out     (sync_out_wire),  // Reset: if LOW, clear counter
        .switch_out   (debounced_out)   // arrow OUT to edge detector
    );

    // ── MODULE 4: EDGE DETECTOR ──────────────────────────────
    // Diagram: right box
    // Converts the stable HIGH level into a SINGLE 1-cycle pulse
    // Without this: holding button = edge_detect_pulse stays HIGH forever
    // With this:    holding button = edge_detect_pulse HIGH for 1 cycle only
    edge_detector u_edge (
        .clk        (clk),
        .switch_out (debounced_out),       // arrow IN from debouncer
        .edge_pulse (edge_detect_pulse)    // arrow OUT across boundary = OUTPUT
    );

endmodule