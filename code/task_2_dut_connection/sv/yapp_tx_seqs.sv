class yapp_base_seq extends uvm_sequence #(yapp_packet);
  
  // Required macro for sequences automation
  `uvm_object_utils(yapp_base_seq)

  // Constructor
  function new(string name="yapp_base_seq");
    super.new(name);
  endfunction

  task pre_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      // in UVM1.2, get starting phase from method
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.raise_objection(this, get_type_name());
      `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
    end
  endtask : pre_body

  task post_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      // in UVM1.2, get starting phase from method
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.drop_objection(this, get_type_name());
      `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
    end
  endtask : post_body

endclass : yapp_base_seq

//------------------------------------------------------------------------------
//
// SEQUENCE: yapp_5_packets
//
//  Configuration setting for this sequence
//    - update <path> to be hierarchial path to sequencer 
//
//  uvm_config_wrapper::set(this, "<path>.run_phase",
//                                 "default_sequence",
//                                 yapp_5_packets::get_type());
//
//------------------------------------------------------------------------------
class yapp_5_packets extends yapp_base_seq;
  
  // Required macro for sequences automation
  `uvm_object_utils(yapp_5_packets)

  // Constructor
  function new(string name="yapp_5_packets");
    super.new(name);
  endfunction

  // Sequence body definition
  virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_5_packets sequence", UVM_LOW)
     repeat(5)
      `uvm_do(req)
  endtask
  
endclass : yapp_5_packets

//--------------------------------------------------------------------------------
//                              yapp_1_seq
//--------------------------------------------------------------------------------

class yapp_1_seq extends yapp_base_seq;
  `uvm_object_utils(yapp_1_seq)

  function new (string name = "yapp_1_seq");
    super.new(name);
  endfunction: new

  task body();
    `uvm_info(get_type_name(), "Executing yapp_1_seq sequence", UVM_LOW)
    `uvm_do_with(req, {addr==1;})
  endtask: body

endclass: yapp_1_seq

//--------------------------------------------------------------------------------
//                              yapp_012_seq
//--------------------------------------------------------------------------------

class yapp_012_seq extends yapp_base_seq;
  `uvm_object_utils(yapp_012_seq)

  function new (string name = "yapp_012_seq");
    super.new(name);
  endfunction: new

  task body();
    bit ok;
    `uvm_info(get_type_name(), "Executing yapp_012 seq", UVM_LOW)
      `uvm_do_with(req, {addr == 0;})
      `uvm_do_with(req, {addr == 1;})
      //`uvm_do_with(req, {addr == 2;})
      `uvm_create(req);
      start_item(req);
      req.select = 1;
      ok = req.randomize() with {addr == 2;};
      assert (ok);
      finish_item(req);
  endtask: body

endclass: yapp_012_seq

//--------------------------------------------------------------------------------
//                              yapp_111_seq
//--------------------------------------------------------------------------------

class yapp_111_seq extends yapp_base_seq;
  `uvm_object_utils(yapp_111_seq)

  function new (string name = "yapp_111_seq");
    super.new(name);
  endfunction: new

  task body();
    `uvm_info(get_type_name(), "Executing yapp_111_seq seq", UVM_LOW)
    repeat(3)
      `uvm_do_with(req, {addr == 1;})
  endtask: body

endclass: yapp_111_seq

//--------------------------------------------------------------------------------
//                              yapp_repeat_addr_seq
//--------------------------------------------------------------------------------

class yapp_repeat_addr_seq extends yapp_base_seq;
  `uvm_object_utils(yapp_repeat_addr_seq)

  function new (string name = "yapp_repeat_addr_seq");
    super.new(name);
  endfunction: new

  task body();
    int prev_addr;
    bit ok;
    `uvm_info(get_type_name(), "Executing yapp_repeat_addr_seq seq", UVM_LOW)
    `uvm_create(req);
    start_item(req);
    ok = req.randomize();
    prev_addr = req.addr;
    finish_item(req);
    // `uvm_do(req)
    prev_addr = req.addr;
    `uvm_do_with(req, {addr == prev_addr;})
  endtask: body

endclass: yapp_repeat_addr_seq

//--------------------------------------------------------------------------------
//                              yapp_incr_payload_seq
//--------------------------------------------------------------------------------

class yapp_incr_payload_seq extends yapp_base_seq;
  `uvm_object_utils(yapp_incr_payload_seq)

  function new (string name = "yapp_incr_payload_seq");
    super.new(name);
  endfunction:new

  task body();
    bit ok;
    `uvm_info(get_type_name(), "Executing yapp_incr_payload_seq seq", UVM_LOW)

    `uvm_create(req)
    ok = req.randomize();
    assert(ok);
    req.payload = new [req.length];
    foreach(req.payload[i])
      req.payload[i] = i;

    `uvm_send(req)
  endtask: body

endclass: yapp_incr_payload_seq

//--------------------------------------------------------------------------------
//                              yapp_rnd_seq
//--------------------------------------------------------------------------------

class yapp_rnd_seq extends yapp_base_seq;
  `uvm_object_utils(yapp_rnd_seq)

  rand int count;

  function new (string name = "yapp_rnd_seq");
    super.new(name);
  endfunction: new

  constraint count_range{
    count inside {[1:10]};
  }


  task body();
    bit ok;
    `uvm_info(get_type_name(), "Executing yapp_rnd_seq sequence", UVM_LOW)
    ok = this.randomize();
    `uvm_info("Count", $sformatf("Count : %0d", count), UVM_LOW)
    assert (ok);
    repeat(count)
    begin
      `uvm_do(req);
    end
  endtask: body

endclass: yapp_rnd_seq

//--------------------------------------------------------------------------------
//                              six_yapp_seq
//--------------------------------------------------------------------------------

class six_yapp_seq extends yapp_base_seq;
  `uvm_object_utils(six_yapp_seq)

  function new (string name = "six_yapp_seq");
    super.new(name);
  endfunction: new

  yapp_rnd_seq six;

  task body();
    bit ok;
    `uvm_info(get_type_name(), "Executing six_yapp_seq sequence", UVM_LOW)
    `uvm_create(six)
    six.count.rand_mode(0);
    six.count = 6;
    //ok = six.randomize();
    `uvm_send(six)

  endtask: body
  
endclass: six_yapp_seq

//--------------------------------------------------------------------------------
//                              yapp_exhaustive_seq
//--------------------------------------------------------------------------------

class yapp_exhaustive_seq extends yapp_base_seq;
  `uvm_object_utils(yapp_exhaustive_seq)

  function new (string name = "yapp_exhaustive_seq");
    super.new(name);
  endfunction: new

  yapp_1_seq s1;
  yapp_012_seq s2;
  yapp_111_seq s3;
  yapp_repeat_addr_seq s4;
  yapp_incr_payload_seq s5;
  yapp_rnd_seq s6;
  six_yapp_seq s7;

  task body();
    `uvm_info(get_type_name(), "Executing yapp_exhaustive_seq seq", UVM_LOW)

    `uvm_do(s1)
    `uvm_do(s2)
    `uvm_do(s3)
    `uvm_do(s4)
    `uvm_do(s5)
    `uvm_do(s6)
    `uvm_do(s7)

  endtask: body

endclass: yapp_base_seq