task run_test();
    reg[31:0] rdata;
    begin
        $display("=================================================");
        $display("====  TEST CASE: RESERVED ADDRESS CHECK (RAZ/WI) ======");
        $display("=================================================");

// step 1
test_bench.apb_wr(12'h020, 32'hAAAA_AAAA);
test_bench.apb_rd(12'h020, rdata);
test_bench.cmp_data(12'h020, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

// step 2
test_bench.apb_wr(12'h020, 32'h5555_5555);
test_bench.apb_rd(12'h020, rdata);
test_bench.cmp_data(12'h020, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

// step 3
test_bench.apb_wr(12'h800, 32'hAAAA_AAAA);
test_bench.apb_rd(12'h800, rdata);
test_bench.cmp_data(12'h800, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(12'h800, 32'h5555_5555);
test_bench.apb_rd(12'h800, rdata);
test_bench.cmp_data(12'h800, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

// step 4
test_bench.apb_wr(12'h804, 32'hAAAA_AAAA);
test_bench.apb_rd(12'h804, rdata);
test_bench.cmp_data(12'h804, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(12'h804, 32'h5555_5555);
test_bench.apb_rd(12'h804, rdata);
test_bench.cmp_data(12'h804, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

// step 5
test_bench.apb_wr(12'hFFF, 32'hAAAA_AAAA);
test_bench.apb_rd(12'hFFF, rdata);
test_bench.cmp_data(12'hFFF, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(12'hFFF, 32'h5555_5555);
test_bench.apb_rd(12'hFFF, rdata);
test_bench.cmp_data(12'hFFF, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

    end
endtask
