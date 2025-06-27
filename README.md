# UVM Lab # 3: Generating UVM Sequences & Connection to DUT

## Table of Contents

- [Task_1](#task_1)
  - [1. Creating Sequences](#1-Creating_Sequences)
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
        set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
        uvm_config_wrapper::set(this, "tb.uvc.agent.sequencer.run_phase", "default_sequence", yapp_1_seq::get_type());
        super.build_phase(phase);
    endfunction: build_phase

endclass: incr_payload_test
```

The topology also confirms that the new test was executed and the sequence is also `yapp_1_seq` which is also confirmed from the printed message that was added in the `seq_1_seq` class i.e *Executing yapp_1_seq sequence*.

`topology`

![screenshot-1](/screenshots/1.png)

`packet`

![screenshot-2](/screenshots/2.png)