class yapp_tx_monitor extends uvm_monitor;

    `uvm_component_utils(yapp_tx_monitor)

    yapp_packet pkt;
    int num_pkt_col;
    virtual yapp_if vif;

    function new (string name = "yapp_tx_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    function void connect_phase(uvm_phase phase);
        //yapp_vif_config::get(this,"","vif", vif);

        if (!yapp_vif_config::get(this,"","vif", vif))
            `uvm_error("NOVIF", "VIF in Monitor is Not SET...")

    endfunction: connect_phase

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Running Simulation ...", UVM_HIGH);
    endfunction: start_of_simulation_phase

    task run_phase(uvm_phase phase);
       @(posedge vif.reset)
       @(negedge vif.reset)
       `uvm_info(get_type_name(), "Detected Reset Done", UVM_MEDIUM)

       forever begin
            pkt = yapp_packet::type_id::create("pkt", this);

            fork
                vif.collect_packet(pkt.length, pkt.addr, pkt.payload, pkt.parity);
                @(posedge vif.monstart) void'(begin_tr(pkt, "Monitor_YAPP_Packet"));
            join

            pkt.parity_type = (pkt.parity == pkt.calc_parity()) ? GOOD_PARITY : BAD_PARITY;

       end_tr(pkt);
        `uvm_info(get_type_name(), $sformatf("Packet Collected :\n%s", pkt.sprint()), UVM_LOW)
        num_pkt_col++;
       end

    endtask: run_phase

    //UVM Report Phase

    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("Report: YAPP Monitor Collected %0d Packets", num_pkt_col), UVM_LOW)
    endfunction : report_phase

endclass: yapp_tx_monitor