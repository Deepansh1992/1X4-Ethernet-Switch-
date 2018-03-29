// Macros Definition 

`ifndef GUARD_GLOBALS
`define GUARD_GLOBALS

`define P0 8'h00
`define P1 8'h11
`define P2 8'h22
`define P3 8'h33

int error = 0;
int num_of_pkts = 10;

`endif

// All the test cases are fed to the DUT

`ifndef GUARD_TOP
`define GUARD_TOP

module top();

/////////////////////////////////////////////////////
// Clock Declaration and Generation                //
/////////////////////////////////////////////////////
bit Clock;

initial
  forever #10 Clock = ~Clock;

/////////////////////////////////////////////////////
//  Memory interface instance                      //
/////////////////////////////////////////////////////

mem_interface mem_intf(Clock);

/////////////////////////////////////////////////////
//  Input interface instance                       //
/////////////////////////////////////////////////////

input_interface input_intf(Clock);

/////////////////////////////////////////////////////
//  output interface instance                      //
/////////////////////////////////////////////////////

output_interface output_intf[4](Clock);

/////////////////////////////////////////////////////
//  Program block Testcase instance                //
/////////////////////////////////////////////////////

testcase TC (mem_intf,input_intf,output_intf);

/////////////////////////////////////////////////////
//  DUT instance and signal connection             //
/////////////////////////////////////////////////////

switch DUT    (.clk(Clock),
               .reset(input_intf.reset),
               .data_status(input_intf.data_status),
               .data(input_intf.data_in),
               .port0(output_intf[0].data_out),
               .port1(output_intf[1].data_out),
               .port2(output_intf[2].data_out),
               .port3(output_intf[3].data_out),
               .ready_0(output_intf[0].ready),
               .ready_1(output_intf[1].ready),
               .ready_2(output_intf[2].ready),
               .ready_3(output_intf[3].ready),
               .read_0(output_intf[0].read),
               .read_1(output_intf[1].read),
               .read_2(output_intf[2].read),
               .read_3(output_intf[3].read),
               .mem_en(mem_intf.mem_en),
               .mem_rd_wr(mem_intf.mem_rd_wr),
               .mem_add(mem_intf.mem_add),
               .mem_data(mem_intf.mem_data));

endmodule


`endif


`ifndef GUARD_INTERFACE
`define GUARD_INTERFACE

//////////////////////////////////////////
// Interface declaration for the memory///
//////////////////////////////////////////

interface mem_interface(input bit clock);
  logic [7:0] mem_data;
  logic [1:0] mem_add;
  logic       mem_en;
  logic       mem_rd_wr;
  
  clocking cb@(posedge clock);
     default input #1 output #1;
     output     mem_data;
     output      mem_add;
     output mem_en;
     output mem_rd_wr;
  endclocking
  
  modport MEM(clocking cb,input clock);

endinterface

////////////////////////////////////////////
// Interface for the input side of switch.//
// Reset signal is also passed hear.      //
////////////////////////////////////////////
interface input_interface(input bit clock);
  logic           data_status;
  logic     [7:0] data_in;
  logic           reset; 

  clocking cb@(posedge clock);
     default input #1 output #1;
     output    data_status;
     output    data_in;
  endclocking
  
  modport IP(clocking cb,output reset,input clock);
  
endinterface

/////////////////////////////////////////////////
// Interface for the output side of the switch.//
// output_interface is for only one output port//
/////////////////////////////////////////////////

interface output_interface(input bit clock);
  logic    [7:0] data_out;
  logic    ready;
  logic    read;
  
  clocking cb@(posedge clock);
    default input #1 output #1;
    input     data_out;
    input     ready;
    output    read;
  endclocking
  
  modport OP(clocking cb,input clock);

endinterface


//////////////////////////////////////////////////

`endif 

`ifndef GUARD_ENV
`define GUARD_ENV

class Environment ;

  virtual mem_interface.MEM    mem_intf       ;
  virtual input_interface.IP  input_intf     ;
  virtual output_interface.OP output_intf[4] ;

function new(virtual mem_interface.MEM    mem_intf_new       ,
             virtual input_interface.IP  input_intf_new     ,
             virtual output_interface.OP output_intf_new[4] );

  this.mem_intf      = mem_intf_new    ;
  this.input_intf    = input_intf_new  ;
  this.output_intf   = output_intf_new ;
  
  $display(" %0d : Environemnt : created env object",$time);
endfunction : new

function void build();
  $display(" %0d : Environemnt : start of build() method",$time);
  $display(" %0d : Environemnt : end of build() method",$time);
endfunction : build

task reset();
  $display(" %0d : Environemnt : start of reset() method",$time);
  // Drive all DUT inputs to a known state
  mem_intf.cb.mem_data      <= 0;
  mem_intf.cb.mem_add       <= 0;
  mem_intf.cb.mem_en        <= 0;
  mem_intf.cb.mem_rd_wr     <= 0;
  input_intf.cb.data_in     <= 0;
  input_intf.cb.data_status <= 0;
  output_intf[0].cb.read    <= 0;
  output_intf[1].cb.read    <= 0;
  output_intf[2].cb.read    <= 0;
  output_intf[3].cb.read    <= 0;
  
  // Reset the DUT
  input_intf.reset       <= 1;
  repeat (4) @ input_intf.clock;
  input_intf.reset       <= 0;
  
  $display(" %0d : Environemnt : end of reset() method",$time);
endtask : reset

task cfg_dut();
  $display(" %0d : Environemnt : start of cfg_dut() method",$time);
  
  mem_intf.cb.mem_en <= 1;
  @(posedge mem_intf.clock);
  mem_intf.cb.mem_rd_wr <= 1;
  
  @(posedge mem_intf.clock);
  mem_intf.cb.mem_add  <= 8'h0;
  mem_intf.cb.mem_data <= `P0;
  $display(" %0d : Environemnt : Port 0 Address %h ",$time,`P0);
  
  @(posedge mem_intf.clock);
  mem_intf.cb.mem_add  <= 8'h1;
  mem_intf.cb.mem_data <= `P1;
  $display(" %0d : Environemnt : Port 1 Address %h ",$time,`P1);
  
  @(posedge mem_intf.clock);
  mem_intf.cb.mem_add  <= 8'h2;
  mem_intf.cb.mem_data <= `P2;
  $display(" %0d : Environemnt : Port 2 Address %h ",$time,`P2);
  
  @(posedge mem_intf.clock);
  mem_intf.cb.mem_add  <= 8'h3;
  mem_intf.cb.mem_data <= `P3;
  $display(" %0d : Environemnt : Port 3 Address %h ",$time,`P3);
  
  @(posedge mem_intf.clock);
  mem_intf.cb.mem_en    <=0;
  mem_intf.cb.mem_rd_wr <= 0;
  mem_intf.cb.mem_add   <= 0;
  mem_intf.cb.mem_data  <= 0;
  
  
  $display(" %0d : Environemnt : end of cfg_dut() method",$time);
endtask : cfg_dut

task start();
  $display(" %0d : Environemnt : start of start() method",$time);
  $display(" %0d : Environemnt : end of start() method",$time);
endtask : start

task wait_for_end();
  $display(" %0d : Environemnt : start of wait_for_end() method",$time);
  repeat(10000) @(input_intf.clock);
  $display(" %0d : Environemnt : end of wait_for_end() method",$time);
endtask : wait_for_end

task run();
  $display(" %0d : Environemnt : start of run() method",$time);
  build();
  reset();
  cfg_dut();
  start();
  wait_for_end();
  report();
  $display(" %0d : Environemnt : end of run() method",$time);
endtask : run 

task report();
endtask : report

endclass

`endif

    

`default_nettype none
`ifndef GUARD_TESTCASE
`define GUARD_TESTCASE



program testcase(mem_interface.MEM mem_intf,input_interface.IP input_intf,output_interface.OP output_intf[4]);

Environment env;
  
initial
begin
$display(" ******************* Start of testcase ****************");
env = new(mem_intf,input_intf,output_intf);
env.run();
#1000;
end

final
$display(" ******************** End of testcase *****************");


endprogram 
`endif


