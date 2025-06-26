typedef enum {GOOD_PARITY, BAD_PARITY} parity_type_e;

class yapp_packet extends uvm_sequence_item;

    rand bit [1:0] addr;
    rand bit [5:0] length;
    rand bit [7:0] payload[];
    bit [7:0] parity;

    rand parity_type_e parity_type;

    `uvm_object_utils_begin(yapp_packet)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(length, UVM_ALL_ON)
        `uvm_field_array_int(payload, UVM_ALL_ON)
        `uvm_field_int(parity, UVM_ALL_ON)
        `uvm_field_enum(parity_type_e, parity_type, UVM_ALL_ON)
    `uvm_object_utils_end

    function new (string name = "yapp_packet");
        super.new(name);
    endfunction: new

    function bit [7:0] calc_parity();
        bit [7:0] return_parity = 0;
        foreach(payload[i])
            return_parity = return_parity ^ payload[i];
        return return_parity;
    endfunction: calc_parity

    function void set_parity();
        if (parity_type == GOOD_PARITY)
            parity = calc_parity();
        else
            parity = calc_parity() + 1;
    endfunction: set_parity

    function void post_randomize();
        set_parity();
    endfunction: post_randomize

    rand int packet_delay;

    constraint c_1 {
        packet_delay inside {[1:20]};
        addr inside {[0:2]};
        length inside {[1:63]};
        payload.size() == length;
        parity_type dist {GOOD_PARITY:=5, BAD_PARITY:=1};
    }

endclass: yapp_packet

class short_yapp_packet extends yapp_packet;
    `uvm_object_utils(short_yapp_packet)

    function new (string name = "short_yapp_packet");
        super.new(name);
    endfunction: new

    constraint c_1 {
        addr inside {[0:1]};
        length inside {[1:15]};
    }


endclass: short_yapp_packet