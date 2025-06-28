module tb_top;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import yapp_pkg::*;
    `include "router_tb.sv"
    `include "router_test_lib.sv"

    initial begin
        yapp_vif_config::set(null,"uvm_test_top.tb.uvc.agent.*", "vif", hw_top.in0);
        run_test("task_2_test");
    end

endmodule