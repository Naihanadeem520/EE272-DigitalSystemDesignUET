module ripple_carry (
    input logic [2:0] a, b,
    input logic cin,
    output logic [2:0]sum,
    output logic cout
);
    logic c1, c2;
    full_adder fa0 (
        .a(a[0]),
        .b(b[0]),
        .cin(cin),
        .sum(sum[0]),
        .cout(c1)
    );
    full_adder fa1 (
        .a(a[1]),
        .b(b[1]),
        .cin(c1),
        .sum(sum[1]),
        .cout(c2)
    );
    full_adder fa2 (
        .a(a[2]),
        .b(b[2]),
        .cin(c2),
        .sum(sum[2]),
        .cout(cout)
    );
endmodule