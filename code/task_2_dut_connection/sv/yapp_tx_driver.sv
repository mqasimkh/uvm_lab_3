class yapp_tx_driver extends uvm_driver #(yapp_packet);

    //yapp_packet req; 
    //this req handle is auto created in base class.

    `uvm_component_utils(yapp_tx_driver)

    function new (string name = "yapp_tx_driver", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Running Simulation ...", UVM_HIGH);
    endfunction: start_of_simulation_phase

    task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            send_to_dut(req);
            seq_item_port.item_done();
        end
    endtask: run_phase

    task send_to_dut(yapp_packet req);
        #10ns;
        `uvm_info ("DRIVER", $sformatf("Packet is \n%s", req.sprint()), UVM_LOW);
    endtask: send_to_dut

endclass: yapp_tx_driver