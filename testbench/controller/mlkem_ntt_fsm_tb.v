module mlkem_ntt_fsm_tb;

parameter WIDTH = 12;
parameter Q = 3329;
parameter N = 256;
parameter ADDR_WIDTH = 8;

reg clk;
reg rst_n;
reg start;
reg is_intt;
wire done;
reg load_en;
reg [ADDR_WIDTH-1:0] load_addr;
reg [WIDTH-1:0] load_data;
reg read_en;
reg [ADDR_WIDTH-1:0] read_addr;
wire [WIDTH-1:0] read_data;

reg [WIDTH-1:0] ntt_input [0:N-1];
reg [WIDTH-1:0] ntt_expected [0:N-1];
reg [WIDTH-1:0] intt_expected [0:N-1];

integer i;
integer errors;
integer w;

mlkem_ntt_fsm #(.WIDTH(WIDTH), .Q(Q), .N(N), .ADDR_WIDTH(ADDR_WIDTH)) dut (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .is_intt(is_intt),
    .done(done),
    .load_en(load_en),
    .load_addr(load_addr),
    .load_data(load_data),
    .read_en(read_en),
    .read_addr(read_addr),
    .read_data(read_data)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    $dumpfile("mlkem_ntt_fsm_tb.vcd");
    $dumpvars(0, mlkem_ntt_fsm_tb);

    $readmemh("../inputs/mlkem_ntt_input.hex", ntt_input);
    $readmemh("../expected/mlkem_ntt_expected.hex", ntt_expected);
    $readmemh("../expected/mlkem_intt_expected.hex", intt_expected);

    rst_n = 0;
    start = 0;
    is_intt = 0;
    load_en = 0;
    read_en = 0;
    load_addr = 0;
    load_data = 0;
    read_addr = 0;
    @(negedge clk);
    @(negedge clk);
    rst_n = 1;

    $display("=== FORWARD NTT ===");
    for (i = 0; i < N; i = i + 1) begin
        load_en = 1;
        load_addr = i;
        load_data = ntt_input[i];
        @(negedge clk);
    end
    load_en = 0;

    start = 1;
    is_intt = 0;
    @(negedge clk);
    start = 0;

    w = 0;
    while (!done && w < 50000) begin
        @(negedge clk);
        w = w + 1;
    end
    if (!done) begin
        $display("WATCHDOG TIMEOUT on NTT after %0d cycles", w);
        $finish;
    end
    $display("NTT computation complete after %0d cycles", w);

    errors = 0;
    for (i = 0; i < N; i = i + 1) begin
        read_en = 1;
        read_addr = i;
        @(negedge clk);
        @(negedge clk);
        if (read_data !== ntt_expected[i]) begin
            errors = errors + 1;
            if (errors < 10) begin
                $display("NTT MISMATCH i=%0d got=%0d expected=%0d", i, read_data, ntt_expected[i]);
            end
        end
    end
    read_en = 0;
    if (errors == 0) begin
        $display("NTT PASS all %0d values match golden model", N);
    end else begin
        $display("NTT FAIL %0d mismatches", errors);
    end

    $display("=== INVERSE NTT (roundtrip) ===");
    rst_n = 0;
    @(negedge clk);
    @(negedge clk);
    rst_n = 1;

    for (i = 0; i < N; i = i + 1) begin
        load_en = 1;
        load_addr = i;
        load_data = ntt_expected[i];
        @(negedge clk);
    end
    load_en = 0;

    start = 1;
    is_intt = 1;
    @(negedge clk);
    start = 0;

    w = 0;
    while (!done && w < 50000) begin
        @(negedge clk);
        w = w + 1;
    end
    if (!done) begin
        $display("WATCHDOG TIMEOUT on INTT after %0d cycles", w);
        $finish;
    end
    $display("INTT computation complete after %0d cycles", w);

    errors = 0;
    for (i = 0; i < N; i = i + 1) begin
        read_en = 1;
        read_addr = i;
        @(negedge clk);
        @(negedge clk);
        if (read_data !== intt_expected[i]) begin
            errors = errors + 1;
            if (errors < 10) begin
                $display("INTT MISMATCH i=%0d got=%0d expected=%0d", i, read_data, intt_expected[i]);
            end
        end
    end
    read_en = 0;
    if (errors == 0) begin
        $display("INTT PASS all %0d values match golden model", N);
    end else begin
        $display("INTT FAIL %0d mismatches", errors);
    end

    $finish;
end

endmodule

