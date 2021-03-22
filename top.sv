
module top#(
   parameter Lo=32'd0,
   parameter Hi=32'd15359
   ) ();
	timeunit 1ns; timeprecision 1ps;
	
	bit clk =1, rst =1;
	
	always #5 clk = ~clk;
	
	initial begin
		#2 rst = 0;
	end
	
	memoryIF memif(.*);
	cpu_cacheIF cpuif(.*);

	MemoryModel #(.Lo(Lo), .Hi(Hi)) Mem (.memBus(memif.slave));	
	CPU         #(.Lo(Lo), .Hi(Hi)) cpu (.cpubus(cpuif.leader));
	
	dm_cache_fsm cache(.clk(clk),.rst(rst),.cpuBus(cpuif.follower), .memBus(memif.master));
   	


endmodule
