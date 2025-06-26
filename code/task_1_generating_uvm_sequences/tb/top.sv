module top;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import yapp_pkg::*;
    `include "router_tb.sv"
    `include "router_test_lib.sv"

    initial begin
        run_test("set_config_test");
    end

    // yapp_packet p1, p2, p3;
    // bit ok;
    
    // initial begin
    //     p1 = new ("p1");
    //     ok = p1.randomize();
    //     assert (ok) else $error("Randomization Failed");
    //     p1.print();

    // end

endmodule