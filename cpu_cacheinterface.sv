interface cpu_cacheIF(input bit clk, input bit rst);
	timeunit 1ns; timeprecision 1ps;
	bit [31:0]addr; //32-bit request addr
	bit [31:0]rd_data; //32-bit request data (used when read)
	bit [31:0]wr_data; //32-bit request data (used when write)
	bit rw; //request type : 0 = read, 1 = write
	bit valid;
	bit ready;
	
	task read(input bit [31:0]addin, output bit [31:0] din);
		$display("CPU issued a load instruction from address = %h",addin);
		addr=addin;     
		rw=1'b0;
        	valid=1'b1;
		#20 valid=1'b0;	
    		forever begin
			@(posedge clk);
				if(ready)
				begin
					din=rd_data;
					break;
				end
        	end
	endtask
	task write(input bit [31:0]addin, input bit [31:0] din);
		$display("CPU issued a store instruction to address = %h with data = %h",addin, din);
		wr_data=din;
		addr=addin;
		rw=1'b1;
		valid=1'b1;
		#20 valid=1'b0;
		forever begin
			@(posedge clk);
			if(ready)
				break;
	end
endtask
  
	modport leader(import read, import write, input clk, input rst, output addr, output wr_data, output rw, output valid, input ready, input rd_data);

  	modport follower(input clk, input  rst, input addr, input wr_data, input rw, input valid, output ready, output rd_data);

endinterface:cpu_cacheIF
