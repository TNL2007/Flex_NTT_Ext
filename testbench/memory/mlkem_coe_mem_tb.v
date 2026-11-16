module mlkem_coe_mem_tb;

parameter WIDTH = 12;
parameter DEPTH = 256;
parameter ADDR_WIDTH = 8;

reg clk;
reg wr_en;
reg [ADDR_WIDTH-1:0] waddr;
reg [WIDTH-1:0] wdata;
reg [ADDR_WIDTH-1:0] raddr;
wire [WIDTH-1:0] rdata;

integer errors;
integer i;
integer expected;

mlkem_coe_mem #(.WIDTH(WIDTH), .DEPTH(DEPTH), .ADDR_WIDTH(ADDR_WIDTH)) dut (
    .clk(clk),
    .wr_en(wr_en),
    .waddr(waddr),
    .wdata(wdata),
    .raddr(raddr),
    .rdata(rdata)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    $dumpfile("mlkem_coe_mem_tb.vcd");
    $dumpvars(0, mlkem_coe_mem_tb);

    wr_en = 0;
    waddr = 0;
    wdata = 0;
    raddr = 0;
    @(negedge clk);

    for (i = 0; i < DEPTH; i = i + 1) begin
        wr_en = 1;
        waddr = i;
        wdata = (i * 13 + 7) % 3329;
        @(negedge clk);
    end
    wr_en = 0;

    $display("write phase complete");

    errors = 0;
    for (i = 0; i < DEPTH; i = i + 1) begin
        raddr = i;
        @(negedge clk);
        @(negedge clk);
        expected = (i * 13 + 7) % 3329;
        if (rdata !== expected) begin
            errors = errors + 1;
            if (errors < 10) begin
                $display("MISMATCH addr=%0d got=%0d expected=%0d", i, rdata, expected);
            end
        end
    end
    if (errors == 0) begin
        $display("FULL MEMORY SWEEP PASS all %0d locations correct", DEPTH);
    end else begin
        $display("FULL MEMORY SWEEP FAIL %0d mismatches", errors);
    end

    wr_en = 1;
    waddr = 5;
    wdata = 3000;
    @(negedge clk);
    wr_en = 0;
    raddr = 4;
    @(negedge clk);
    @(negedge clk);
    if (rdata !== ((4 * 13 + 7) % 3329)) begin
        $display("ISOLATION FAIL addr=4 corrupted by write to addr=5, got=%0d", rdata);
    end else begin
        $display("ISOLATION PASS addr=4 unaffected by write to addr=5");
    end
    raddr = 5;
    @(negedge clk);
    @(negedge clk);
    if (rdata !== 3000) begin
        $display("ISOLATION FAIL addr=5 did not update, got=%0d", rdata);
    end else begin
        $display("ISOLATION PASS addr=5 correctly updated to 3000");
    end

    $finish;
end

endmodule