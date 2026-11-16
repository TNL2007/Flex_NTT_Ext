module mlkem_tf_mem_tb;

parameter WIDTH = 12;
parameter ADDR_WIDTH = 7;

reg [ADDR_WIDTH-1:0] addr;
reg sel_gamma;
wire [WIDTH-1:0] data;
integer errors;
integer i;
reg [WIDTH-1:0] expected;

mlkem_tf_mem #(.WIDTH(WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) dut (
    .addr(addr),
    .sel_gamma(sel_gamma),
    .data(data)
);

initial begin
    $dumpfile("mlkem_tf_mem_tb.vcd");
    $dumpvars(0, mlkem_tf_mem_tb);

    addr = 0; sel_gamma = 0; #10;
    $display("t=%0t addr=%0d sel_gamma=%0d data=%0d expected=%0d", $time, addr, sel_gamma, data, 1);

    addr = 1; sel_gamma = 0; #10;
    $display("t=%0t addr=%0d sel_gamma=%0d data=%0d expected=%0d", $time, addr, sel_gamma, data, 1729);

    addr = 127; sel_gamma = 0; #10;
    $display("t=%0t addr=%0d sel_gamma=%0d data=%0d expected=%0d", $time, addr, sel_gamma, data, 2154);

    addr = 0; sel_gamma = 1; #10;
    $display("t=%0t addr=%0d sel_gamma=%0d data=%0d expected=%0d", $time, addr, sel_gamma, data, 17);

    addr = 1; sel_gamma = 1; #10;
    $display("t=%0t addr=%0d sel_gamma=%0d data=%0d expected=%0d", $time, addr, sel_gamma, data, 3312);

    addr = 127; sel_gamma = 1; #10;
    $display("t=%0t addr=%0d sel_gamma=%0d data=%0d expected=%0d", $time, addr, sel_gamma, data, 1175);

    errors = 0;
    sel_gamma = 0;
    for (i = 0; i < 128; i = i + 1) begin
        addr = i;
        #1;
        case (i)
            0: expected = 1;
            1: expected = 1729;
            2: expected = 2580;
            3: expected = 3289;
            4: expected = 2642;
            5: expected = 630;
            6: expected = 1897;
            7: expected = 848;
            8: expected = 1062;
            9: expected = 1919;
            10: expected = 193;
            11: expected = 797;
            12: expected = 2786;
            13: expected = 3260;
            14: expected = 569;
            15: expected = 1746;
            16: expected = 296;
            17: expected = 2447;
            18: expected = 1339;
            19: expected = 1476;
            20: expected = 3046;
            21: expected = 56;
            22: expected = 2240;
            23: expected = 1333;
            24: expected = 1426;
            25: expected = 2094;
            26: expected = 535;
            27: expected = 2882;
            28: expected = 2393;
            29: expected = 2879;
            30: expected = 1974;
            31: expected = 821;
            32: expected = 289;
            33: expected = 331;
            34: expected = 3253;
            35: expected = 1756;
            36: expected = 1197;
            37: expected = 2304;
            38: expected = 2277;
            39: expected = 2055;
            40: expected = 650;
            41: expected = 1977;
            42: expected = 2513;
            43: expected = 632;
            44: expected = 2865;
            45: expected = 33;
            46: expected = 1320;
            47: expected = 1915;
            48: expected = 2319;
            49: expected = 1435;
            50: expected = 807;
            51: expected = 452;
            52: expected = 1438;
            53: expected = 2868;
            54: expected = 1534;
            55: expected = 2402;
            56: expected = 2647;
            57: expected = 2617;
            58: expected = 1481;
            59: expected = 648;
            60: expected = 2474;
            61: expected = 3110;
            62: expected = 1227;
            63: expected = 910;
            64: expected = 17;
            65: expected = 2761;
            66: expected = 583;
            67: expected = 2649;
            68: expected = 1637;
            69: expected = 723;
            70: expected = 2288;
            71: expected = 1100;
            72: expected = 1409;
            73: expected = 2662;
            74: expected = 3281;
            75: expected = 233;
            76: expected = 756;
            77: expected = 2156;
            78: expected = 3015;
            79: expected = 3050;
            80: expected = 1703;
            81: expected = 1651;
            82: expected = 2789;
            83: expected = 1789;
            84: expected = 1847;
            85: expected = 952;
            86: expected = 1461;
            87: expected = 2687;
            88: expected = 939;
            89: expected = 2308;
            90: expected = 2437;
            91: expected = 2388;
            92: expected = 733;
            93: expected = 2337;
            94: expected = 268;
            95: expected = 641;
            96: expected = 1584;
            97: expected = 2298;
            98: expected = 2037;
            99: expected = 3220;
            100: expected = 375;
            101: expected = 2549;
            102: expected = 2090;
            103: expected = 1645;
            104: expected = 1063;
            105: expected = 319;
            106: expected = 2773;
            107: expected = 757;
            108: expected = 2099;
            109: expected = 561;
            110: expected = 2466;
            111: expected = 2594;
            112: expected = 2804;
            113: expected = 1092;
            114: expected = 403;
            115: expected = 1026;
            116: expected = 1143;
            117: expected = 2150;
            118: expected = 2775;
            119: expected = 886;
            120: expected = 1722;
            121: expected = 1212;
            122: expected = 1874;
            123: expected = 1029;
            124: expected = 2110;
            125: expected = 2935;
            126: expected = 885;
            127: expected = 2154;
        endcase
        if (data !== expected) begin
            errors = errors + 1;
            $display("ZETAS MISMATCH addr=%0d got=%0d expected=%0d", i, data, expected);
        end
    end
    sel_gamma = 1;
    for (i = 0; i < 128; i = i + 1) begin
        addr = i;
        #1;
        case (i)
            0: expected = 17;
            1: expected = 3312;
            2: expected = 2761;
            3: expected = 568;
            4: expected = 583;
            5: expected = 2746;
            6: expected = 2649;
            7: expected = 680;
            8: expected = 1637;
            9: expected = 1692;
            10: expected = 723;
            11: expected = 2606;
            12: expected = 2288;
            13: expected = 1041;
            14: expected = 1100;
            15: expected = 2229;
            16: expected = 1409;
            17: expected = 1920;
            18: expected = 2662;
            19: expected = 667;
            20: expected = 3281;
            21: expected = 48;
            22: expected = 233;
            23: expected = 3096;
            24: expected = 756;
            25: expected = 2573;
            26: expected = 2156;
            27: expected = 1173;
            28: expected = 3015;
            29: expected = 314;
            30: expected = 3050;
            31: expected = 279;
            32: expected = 1703;
            33: expected = 1626;
            34: expected = 1651;
            35: expected = 1678;
            36: expected = 2789;
            37: expected = 540;
            38: expected = 1789;
            39: expected = 1540;
            40: expected = 1847;
            41: expected = 1482;
            42: expected = 952;
            43: expected = 2377;
            44: expected = 1461;
            45: expected = 1868;
            46: expected = 2687;
            47: expected = 642;
            48: expected = 939;
            49: expected = 2390;
            50: expected = 2308;
            51: expected = 1021;
            52: expected = 2437;
            53: expected = 892;
            54: expected = 2388;
            55: expected = 941;
            56: expected = 733;
            57: expected = 2596;
            58: expected = 2337;
            59: expected = 992;
            60: expected = 268;
            61: expected = 3061;
            62: expected = 641;
            63: expected = 2688;
            64: expected = 1584;
            65: expected = 1745;
            66: expected = 2298;
            67: expected = 1031;
            68: expected = 2037;
            69: expected = 1292;
            70: expected = 3220;
            71: expected = 109;
            72: expected = 375;
            73: expected = 2954;
            74: expected = 2549;
            75: expected = 780;
            76: expected = 2090;
            77: expected = 1239;
            78: expected = 1645;
            79: expected = 1684;
            80: expected = 1063;
            81: expected = 2266;
            82: expected = 319;
            83: expected = 3010;
            84: expected = 2773;
            85: expected = 556;
            86: expected = 757;
            87: expected = 2572;
            88: expected = 2099;
            89: expected = 1230;
            90: expected = 561;
            91: expected = 2768;
            92: expected = 2466;
            93: expected = 863;
            94: expected = 2594;
            95: expected = 735;
            96: expected = 2804;
            97: expected = 525;
            98: expected = 1092;
            99: expected = 2237;
            100: expected = 403;
            101: expected = 2926;
            102: expected = 1026;
            103: expected = 2303;
            104: expected = 1143;
            105: expected = 2186;
            106: expected = 2150;
            107: expected = 1179;
            108: expected = 2775;
            109: expected = 554;
            110: expected = 886;
            111: expected = 2443;
            112: expected = 1722;
            113: expected = 1607;
            114: expected = 1212;
            115: expected = 2117;
            116: expected = 1874;
            117: expected = 1455;
            118: expected = 1029;
            119: expected = 2300;
            120: expected = 2110;
            121: expected = 1219;
            122: expected = 2935;
            123: expected = 394;
            124: expected = 885;
            125: expected = 2444;
            126: expected = 2154;
            127: expected = 1175;
        endcase
        if (data !== expected) begin
            errors = errors + 1;
            $display("GAMMAS MISMATCH addr=%0d got=%0d expected=%0d", i, data, expected);
        end
    end
    if (errors == 0) begin
        $display("FULL ROM SWEEP PASS all 256 entries correct");
    end else begin
        $display("FULL ROM SWEEP FAIL %0d mismatches", errors);
    end

    $finish;
end

endmodule