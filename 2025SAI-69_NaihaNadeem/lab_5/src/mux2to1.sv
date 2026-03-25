module mux2to1 (
    input  logic sel,
    input  logic d0, d1,
    output logic y
);
    always_comb begin
        if (sel) y = d1;
        else     y = d0;
    end
endmodule