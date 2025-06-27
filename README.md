# UVM Lab # 3: Generating UVM Sequences & Connection to DUT

## Table of Contents

- [Task_1](#task_1)
  - [1. Creating Sequences](#1_Creating_Sequences)
    - [yapp_1_seq](#yapp_1_seq)
---

## Task_1

In this task, need to create different sequences and learn about objection mechanism.

### 1. Creating Sequences

#### yapp_1_seq

Created a new sequence in `yapp_tx_seqs.sv` file with constraint that `addr == 1`. 

```systemverilog
class yapp_1_seq extends yapp_base_seq;
  `uvm_object_utils(yapp_1_seq)

  function new (string name = "yapp_1_seq");
    super.new(name);
  endfunction: new

  virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_1_seq sequence", UVM_LOW)
    `uvm_do_with(req, {addr==1;})
  endtask: body

endclass: yapp_1_seq
```

To test that it is working, created a new test named `incr_payload_test` in `router_test_lib.sv`.

In the test set default sequence to newly created one using uvm_config_wrapper::set method. Ran the test to verify the results, and it is as expected.

```systemverilog
class incr_payload_test extends base_test;
    `uvm_component_utils(incr_payload_test)

    function new (string name = "incr_payload_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
        uvm_config_wrapper::set(this, "tb.uvc.agent.sequencer.run_phase", "default_sequence", yapp_1_seq::get_type());
    endfunction: build_phase

endclass: incr_payload_test
```

The topology also confirms that the new test was executed and the sequence is also `yapp_1_seq` which is also confirmed from the printed message that was added in the `seq_1_seq` class i.e *Executing yapp_1_seq sequence*.

`topology`

![screenshot-1](/screenshots/1.png)

`packet`

![screenshot-2](/screenshots/2.png)

#### yapp_012_seq

Created a new sequence named `yapp_012_seq` which generates 3 packets with addr 0, 1 & 2. 

```systemverilog
class yapp_012_seq extends yapp_base_seq;
  `uvm_object_utils(yapp_012_seq)

  function new (string name = "yapp_012_seq");
    super.new(name);
  endfunction: new

  virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_012 seq", UVM_LOW)
      `uvm_do_with(req, {addr == 0;})
      `uvm_do_with(req, {addr == 1;})
      `uvm_do_with(req, {addr == 2;})
  endtask: body

endclass: yapp_012_seq
```

Ran the test with `short_yapp_packet` and as expected the first 2 packets with `addr = 0` and `addr = 1` were generated.

`addr = 2` was not generated because in `short_yapp_packet` we added constraint that addr should be 0 or 1. So gave constraint conflict error.

![screenshot-3](/screenshots/3.png)

#### yapp_111_seq

Created a new sequence named `yapp_111_seq` which generates 3 sequences and addr == 1 in all 3.

```systemverilog
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
```

Ran the test to confirm the packet is generated, and result as expected. 3 packets with `addr == 1` in all 3.

![screenshot-4](/screenshots/4.png)

#### yapp_repeat_addr_seq

Created a new sequence named `yapp_repeat_addr_seq` which generates 2 packets, first one with random addr and second one with all data random except its addr should be equal to previous addr.

So created declated `prev_item` variable `int` data type and created the first packet manually using `start_item()` and `finish_item()` methods.

Stored `req.addr` after randomization in `prev_addr` and created second packet using `uvm_do_with` macro with constraint that `addr == prev_addr`.

```systemverilog
class yapp_repeat_addr_seq extends yapp_base_seq;
  `uvm_object_utils(yapp_repeat_addr_seq)

  function new (string name = "yapp_repeat_addr_seq");
    super.new(name);
  endfunction: new

  task body();
    int prev_addr;
    bit ok;
    `uvm_info(get_type_name(), "Executing yapp_repeat_addr_seq seq", UVM_LOW);
    start_item(req);
    ok = req.randomize();
    prev_addr = req.addr;
    finish_item(req);
    `uvm_do_with(req, {addr == prev_addr;})
  endtask: body

endclass: yapp_repeat_addr_seq
```

Ran the test again to confirm if correct packets are generated and packets not generated and got this error:

![screenshot-5](/screenshots/5.png)

```systemverilog
UVM_FATAL @ 0: uvm_test_top.tb.uvc.agent.sequencer@@yapp_repeat_addr_seq [NULLITM] attempting to start a null item from sequence 'uvm_test_top.tb.uvc.agent.sequencer.yapp_repeat_addr_seq'
```

#### yapp_incr_payload_seq

Created `yapp_incr_payload_seq` sequence which instead of assigning random values to payload[] array, manually assign index to payload.

```systemverilog
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
```

Ran the test again to confirm if correct packets are generated and packets not generated and got this error:

![screenshot-6](/screenshots/6.png)