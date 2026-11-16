module mlkem_ntt_fsm #(
    parameter WIDTH = 12,
    parameter Q = 3329,
    parameter N = 256,
    parameter ADDR_WIDTH = 8
)(
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire is_intt,
    output reg done,
    input wire load_en,
    input wire [ADDR_WIDTH-1:0] load_addr,
    input wire [WIDTH-1:0] load_data,
    input wire read_en,
    input wire [ADDR_WIDTH-1:0] read_addr,
    output wire [WIDTH-1:0] read_data
);

localparam MODE_CT = 2'd0;
localparam MODE_GS = 2'd1;

localparam S_IDLE = 0;
localparam S_ISSUE_A0 = 1;
localparam S_SETTLE_A0 = 2;
localparam S_WAIT_A0 = 3;
localparam S_ISSUE_A1 = 4;
localparam S_SETTLE_A1 = 5;
localparam S_WAIT_A1 = 6;
localparam S_START_RBU = 7;
localparam S_WAIT_RBU = 8;
localparam S_WRITE0 = 9;
localparam S_WRITE1 = 10;
localparam S_ADVANCE = 11;
localparam S_SCALE_ISSUE = 12;
localparam S_SCALE_SETTLE = 13;
localparam S_SCALE_WAIT = 14;
localparam S_SCALE_RBU_START = 15;
localparam S_SCALE_RBU_WAIT = 16;
localparam S_SCALE_WRITE = 17;
localparam S_SCALE_ADVANCE = 18;
localparam S_DONE = 19;

reg [4:0] state;
reg is_intt_latched;
reg [8:0] length;
reg [8:0] start_idx;
reg [8:0] j;
reg [7:0] k;
reg [ADDR_WIDTH-1:0] addr_j;
reg [ADDR_WIDTH-1:0] addr_jl;
reg [WIDTH-1:0] a0_reg;
reg [WIDTH-1:0] a1_reg;
reg [WIDTH-1:0] r0_reg;
reg [WIDTH-1:0] r1_reg;
reg [8:0] scale_i;

reg mem_wr_en;
reg [ADDR_WIDTH-1:0] mem_waddr;
reg [WIDTH-1:0] mem_wdata;
reg [ADDR_WIDTH-1:0] mem_raddr;
wire [WIDTH-1:0] mem_rdata;

wire [WIDTH-1:0] tw;

reg rbu_start;
reg [1:0] rbu_mode;
reg [WIDTH-1:0] rbu_a0;
reg [WIDTH-1:0] rbu_a1;
reg [WIDTH-1:0] rbu_b0;
wire [WIDTH-1:0] rbu_r0;
wire [WIDTH-1:0] rbu_r1;
wire rbu_done;

localparam INV_N = 3303;

mlkem_coe_mem #(.WIDTH(WIDTH), .DEPTH(N), .ADDR_WIDTH(ADDR_WIDTH)) u_mem (
    .clk(clk),
    .wr_en(load_en || mem_wr_en),
    .waddr(load_en ? load_addr : mem_waddr),
    .wdata(load_en ? load_data : mem_wdata),
    .raddr(read_en ? read_addr : mem_raddr),
    .rdata(mem_rdata)
);

assign read_data = mem_rdata;

mlkem_tf_mem #(.WIDTH(WIDTH), .ADDR_WIDTH(7)) u_tf (
    .addr(k[6:0]),
    .sel_gamma(1'b0),
    .data(tw)
);

wire rbu_fault;
reg  fault_latched;

mlkem_rbu #(.WIDTH(WIDTH), .Q(Q)) u_rbu (
    .clk(clk),
    .rst_n(rst_n),
    .start(rbu_start),
    .mode(rbu_mode),
    .a0(rbu_a0),
    .a1(rbu_a1),
    .b0(rbu_b0),
    .b1({WIDTH{1'b0}}),
    .tw(tw),
    .r0(rbu_r0),
    .r1(rbu_r1),
    .done(rbu_done),
    .busy(),
    .fault_detected(rbu_fault)
);

wire [8:0] next_start_idx = start_idx + {length[7:0], 1'b0};

always @(posedge clk) begin
    if (!rst_n) begin
        state <= S_IDLE;
        done <= 0;
        mem_wr_en <= 0;
        rbu_start <= 0;
        rbu_b0 <= 0;
        fault_latched <= 0;
    end else begin
        mem_wr_en <= 0;
        rbu_start <= 0;
        case (state)
            S_IDLE: begin
                done <= 0;
                if (start) begin
                    is_intt_latched <= is_intt;
                    if (is_intt) begin
                        length <= 2;
                        k <= 127;
                        addr_jl <= 2;
                    end else begin
                        length <= 128;
                        k <= 1;
                        addr_jl <= 128;
                    end
                    start_idx <= 0;
                    j <= 0;
                    addr_j <= 0;
                    state <= S_ISSUE_A0;
                end
            end
            S_ISSUE_A0: begin
                mem_raddr <= addr_j;
                state <= S_SETTLE_A0;
            end
            S_SETTLE_A0: begin
                state <= S_WAIT_A0;
            end
            S_WAIT_A0: begin
                a0_reg <= mem_rdata;
                state <= S_ISSUE_A1;
            end
            S_ISSUE_A1: begin
                mem_raddr <= addr_jl;
                state <= S_SETTLE_A1;
            end
            S_SETTLE_A1: begin
                state <= S_WAIT_A1;
            end
            S_WAIT_A1: begin
                a1_reg <= mem_rdata;
                state <= S_START_RBU;
            end
            S_START_RBU: begin
                rbu_a0 <= a0_reg;
                rbu_a1 <= a1_reg;
                rbu_mode <= is_intt_latched ? MODE_GS : MODE_CT;
                rbu_start <= 1;
// synthesis translate_off
                $display("startdbg t=%0t a0_reg=%0d a1_reg=%0d tw=%0d mode=%0d", $time, a0_reg, a1_reg, tw, is_intt_latched ? MODE_GS : MODE_CT);
// synthesis translate_on
                state <= S_WAIT_RBU;
            end
            S_WAIT_RBU: begin
                if (rbu_done) begin
                    if (rbu_fault || fault_latched) begin
                        fault_latched <= 1'b1;
                        mem_wr_en     <= 1'b0;
                        r0_reg        <= {WIDTH{1'b0}};
                        r1_reg        <= {WIDTH{1'b0}};
                        state         <= S_DONE; // Atomic abort: suppress write, halt FSM
                    end else begin
                        r0_reg <= rbu_r0;
                        r1_reg <= rbu_r1;
                        state  <= S_WRITE0;
                    end
                end
            end
            S_WRITE0: begin
                if (!fault_latched && !rbu_fault) begin
                    mem_wr_en <= 1;
                    mem_waddr <= addr_j;
                    mem_wdata <= r0_reg;
                    state <= S_WRITE1;
                end else begin
                    mem_wr_en <= 0;
                    state <= S_DONE;
                end
            end
            S_WRITE1: begin
                if (!fault_latched && !rbu_fault) begin
                    mem_wr_en <= 1;
                    mem_waddr <= addr_jl;
                    mem_wdata <= r1_reg;
                    state <= S_ADVANCE;
                end else begin
                    mem_wr_en <= 0;
                    state <= S_DONE;
                end
            end
            S_ADVANCE: begin
                if (j == start_idx + length - 1) begin
                    if (start_idx + 2 * length >= N) begin
                        if (is_intt_latched) begin
                            k <= k - 1;
                        end else begin
                            k <= k + 1;
                        end
                        if (length == (is_intt_latched ? 128 : 2)) begin
                            if (is_intt_latched) begin
                                scale_i <= 0;
                                state <= S_SCALE_ISSUE;
                            end else begin
                                state <= S_DONE;
                            end
                        end else begin
                            start_idx <= 0;
                            j <= 0;
                            addr_j <= 0;
                            if (is_intt_latched) begin
                                length <= length << 1;
                                addr_jl <= (length << 1);
                            end else begin
                                length <= length >> 1;
                                addr_jl <= (length >> 1);
                            end
                            state <= S_ISSUE_A0;
                        end
                    end else begin
                        start_idx <= next_start_idx;
                        j <= next_start_idx;
                        addr_j <= next_start_idx[ADDR_WIDTH-1:0];
                        addr_jl <= next_start_idx[ADDR_WIDTH-1:0] | length[ADDR_WIDTH-1:0];
                        if (is_intt_latched) begin
                            k <= k - 1;
                        end else begin
                            k <= k + 1;
                        end
                        state <= S_ISSUE_A0;
                    end
                end else begin
                    j <= j + 1;
                    addr_j <= addr_j + 1;
                    addr_jl <= addr_jl + 1;
                    state <= S_ISSUE_A0;
                end
            end
            S_SCALE_ISSUE: begin
                mem_raddr <= scale_i[ADDR_WIDTH-1:0];
                state <= S_SCALE_SETTLE;
            end
            S_SCALE_SETTLE: begin
                state <= S_SCALE_WAIT;
            end
            S_SCALE_WAIT: begin
                a0_reg <= mem_rdata;
                state <= S_SCALE_RBU_START;
            end
            S_SCALE_RBU_START: begin
                rbu_a0 <= a0_reg;
                rbu_b0 <= INV_N[WIDTH-1:0];
                rbu_mode <= 2'd2;
                rbu_start <= 1;
                state <= S_SCALE_RBU_WAIT;
            end
            S_SCALE_RBU_WAIT: begin
                if (rbu_done) begin
                    r0_reg <= rbu_r0;
                    state <= S_SCALE_WRITE;
                end
            end
            S_SCALE_WRITE: begin
                mem_wr_en <= 1;
                mem_waddr <= scale_i[ADDR_WIDTH-1:0];
                mem_wdata <= r0_reg;
                state <= S_SCALE_ADVANCE;
            end
            S_SCALE_ADVANCE: begin
                if (scale_i == N - 1) begin
                    state <= S_DONE;
                end else begin
                    scale_i <= scale_i + 1;
                    state <= S_SCALE_ISSUE;
                end
            end
            S_DONE: begin
                done <= 1;
                state <= S_IDLE;
            end
            default: begin
                state <= S_IDLE;
            end
        endcase
    end
end

endmodule