class base_test extends uvm_test;

    `uvm_component_utils(base_test)

    function new (string name = "base_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    router_tb tb;

    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.uvc.agent.sequencer.run_phase", 
        "default_sequence",
        yapp_5_packets::get_type());

        //tb = new("tb", this);
        tb = router_tb::type_id::create("tb", this);

        `uvm_info(get_type_name(), "Build phase of test is being executed", UVM_HIGH);
        uvm_config_int::set(this, "*", "recording_detail", 1);
    endfunction: build_phase

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Running Simulation ...", UVM_HIGH);
    endfunction: start_of_simulation_phase

    function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction: end_of_elaboration_phase

    function void check_phase(uvm_phase phase);
        check_config_usage();
    endfunction: check_phase

endclass: base_test

/////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////                Short Packet Test                    ////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////

class short_packet_test extends base_test;
    `uvm_component_utils(short_packet_test)

    function new (string name = "short_packet_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
        super.build_phase(phase);
    endfunction: build_phase
endclass: short_packet_test

/////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////                Set Config Test                      ////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////

class set_config_test extends base_test;
    `uvm_component_utils(set_config_test)

    function new (string name = "set_config_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        uvm_config_int::set(this, "tb.uvc.agent", "is_active", UVM_PASSIVE);
        super.build_phase(phase);
    endfunction: build_phase

endclass: set_config_test