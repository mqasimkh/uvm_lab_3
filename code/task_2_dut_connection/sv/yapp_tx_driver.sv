class yapp_tx_driver extends uvm_driver #(yapp_packet);

    //yapp_packet req; 
    //this req handle is auto created in base class.

    `uvm_component_utils(yapp_tx_driver)

    virtual yapp_if vif;
    int num_sent;

    function new (string name = "yapp_tx_driver", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Running Simulation ...", UVM_HIGH);
    endfunction: start_of_simulation_phase

    function void connect_phase(uvm_phase phase);
        if (!yapp_vif_config::get(this,"","vif", vif))
            `uvm_error("NOVIF", "VIF in DRIVER is Not SET...")
    endfunction: connect_phase

    task run_phase(uvm_phase phase);
        fork   
            get_and_drive();
            reset_signals();
        join
    endtask: run_phase

    // Gets packets from the sequencer and passes them to the driver. 
    task get_and_drive();
        @(posedge vif.reset);
        @(negedge vif.reset);
        `uvm_info(get_type_name(), "Reset dropped", UVM_MEDIUM)
        forever begin
            seq_item_port.get_next_item(req);
            `uvm_info(get_type_name(), $sformatf("Sending Packet :\n%s", req.sprint()), UVM_HIGH)
            fork
            // send packet
            begin
            foreach (req.payload[i])
            vif.payload_mem[i] = req.payload[i];
            vif.send_to_dut(req.length, req.addr, req.parity, req.packet_delay);
            end
            @(posedge vif.drvstart) void'(begin_tr(req, "Driver_YAPP_Packet"));
            join
            end_tr(req);
            num_sent++;
            seq_item_port.item_done();
        end
    endtask : get_and_drive

    task reset_signals();
    forever 
    vif.yapp_reset();
    endtask : reset_signals

    // task run_phase(uvm_phase phase);
    //     forever begin
    //         seq_item_port.get_next_item(req);
    //         send_to_dut(req);
    //         seq_item_port.item_done();
    //     end
    // endtask: run_phase

    // task send_to_dut(yapp_packet req);
    //     #10ns;
    //     `uvm_info ("DRIVER", $sformatf("Packet is \n%s", req.sprint()), UVM_LOW);
    // endtask: send_to_dut

endclass: yapp_tx_driver