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
FIXED the error. It was because I was using start_item() & finish_item() methods of sequence without constructing `req`. By default `req` is a handle created for `sequence_item` that is passed as parameter to class.

So created handle for `req` using `uvm_create` macro which is equivalent to:

```systemverilog
req = sequence_item_type::type_id::create::("req", this).
```
`sequence_item_type` here is `yapp_packet`.

![screenshot-5b](/screenshots/5b.png)

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

Ran the test again to confirm if correct packets are generated, and all good till here:

![screenshot-6](/screenshots/6.png)

#### yapp_exhaustive_seq

To test all the sequences, created `yapp_exhaustive_seq` sequence which is nested sequence where created handles for all seuqneces and then created them using `uvm_do` macro. 

Since `uvm_do` macro blocking, all these sequences will be implemented thru sequencer sequentially.

```systemverilog
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

  task body();
    `uvm_info(get_type_name(), "Executing yapp_exhaustive_seq seq", UVM_LOW)

    `uvm_do(s1)
    `uvm_do(s2)
    `uvm_do(s3)
    `uvm_do(s4)
    `uvm_do(s5)

  endtask: body

endclass: yapp_base_seq
```

#### test_exhaustive_seq_test

Created a new test named `test_exhaustive_seq_test` which extends from `base_test`.

In the test set default sequence to `yapp_exhaustive_seq` using uvm_config_wrapper::set method, and set the packet using `set_type_override_by_type` method to `short_yapp_packet`.

Ran the test to test if all sequences are working correctly. All are working correctly, except `yapp_012_seq` due to conflicting constraint.

In `short_yapp_packet` we added constraint that addr can be `0` or `1` but in `yapp_012_seq` we also added that 3rd packet should have `addr == 2`.

Running the test in `gui` mode which stops on constraint violation and shows the line which is causing the contraint conflict.

`Xcellium Terminal`

![screenshot-7](/screenshots/7.png)

`Constraint Debugger`

![screenshot-8](/screenshots/8.png)

Opened the sequences in waveform window, and only 3 transaction are generated, 1 for `yapp_1_seq` and 2 for `yapp_012_seq` as on 3rd where `addr == 2`, the program stopped.

![screenshot-9](/screenshots/9.png)


![screenshot-10](/screenshots/10.png)

FIX

Added a new signal named `select` in base sequence class i.e. `yapp_packet` 

Added `select` in base class because we pass packet base class parameter to `uvm_sequencer` so handle req is created for that class, so to keep things simple and use `req` handle which is created in uvm base_class.

Now `short_yapp_packet` class, edited the constraint so by default select is 0, and when it is zero, it should follow the constraint for addr to be `0` or `1`.

When `select` is `1` this constraint is ignored.

```systemverilog
  constraint c_2 {
    !select -> addr inside {[0:1]};
    length inside {[1:15]};
  }
```

Now in `yapp_012_seq` sequence, select `req.select = 1` and then manually create the packet using `start_item()` and `finish_item()` methods.

```systemverilog
  `uvm_create(req);
  start_item(req);
  req.select = 1;
  ok = req.randomize() with {addr == 2;};
  assert (ok);
  finish_item(req);
```

Re-ran the test, and now all contraint conflicts are clear. Checked the transactions in waveform window and all are created.

![screenshot-11](/screenshots/11.png)

#### yapp_rnd_seq

Created `yapp_rnd_seq` sequence which generates random number of packets between `1` & `10`.

```systemverilog
class yapp_rnd_seq extends yapp_base_seq;
  `uvm_object_utils(yapp_rnd_seq)

  rand int count;

  function new (string name = "yapp_rnd_seq");
    super.new(name);
  endfunction: new

  task body();
    bit ok;
    `uvm_info(get_type_name(), "Executing yapp_rnd_seq sequence", UVM_LOW)
    ok = randomize() with {count inside {[1:10]};};
    `uvm_info("Count", $sformatf("Count : %0d", count), UVM_LOW)
    assert (ok);
    repeat(count)
    begin
      `uvm_do(req);
    end
  endtask: body

endclass: yapp_rnd_seq
```
Tested the sequence and it works fine.

`Count == 9`, so 9 packets should be generated:

![screenshot-12](/screenshots/12.png)

9 Packets generated.

![screenshot-13](/screenshots/13.png)

#### six_yapp_seq

Created `six_yapp_seq` nested sequence where `yapp_rnd_seq` count constraint is fixed to `6`.

```systemverilog
class six_yapp_seq extends yapp_base_seq;
  `uvm_object_utils(six_yapp_seq)

  function new (string name = "six_yapp_seq");
    super.new(name);
  endfunction: new

  yapp_rnd_seq s1;

  task body();
    `uvm_create(s1)
    `uvm_info(get_type_name(), "Executing six_yapp_seq sequence", UVM_LOW)
    s1.count = 6;
    `uvm_do(s1)
  endtask: body
  
endclass: six_yapp_seq
```
Tested and all good.

![screenshot-14](/screenshots/14.png)