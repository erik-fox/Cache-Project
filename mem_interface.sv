interface memoryIF(input bit clk, input bit rst);
	timeunit 1ns; timeprecision 1ps;
	bit [31:0]addr; //32-bit request addr
	bit [511:0]wr_data, rd_data; //512-bit cacheline (used on cache miss)
	bit rw; //request type : 0 = read, 1 = write
	bit valid;
	bit ready;
  /* input cache_def::mem_data_type mem_data, output cache_def::mem_req_type mem_req */
  	modport master(input clk, input rst, output addr,output wr_data, input rd_data, output rw, output valid, input ready);
  	modport slave(input clk, input rst, input addr, input wr_data, output rd_data, input rw, input valid, output ready);

endinterface

