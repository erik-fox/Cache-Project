module cpu_cacheIFTB();
 	bit clock,reset;
  	cpu_cacheIF cpubus(clock,reset);
  MEM m0(cpubus.follower);
  CPU c0( cpubus.leader);
  initial
    begin
      	$dumpfile("dump.vcd"); $dumpvars;
		clock = 1'b0;
		forever #10 clock = ~clock;
    end
  initial
    begin
      #100
   		$finish;
    end
endmodule

module MEM (cpu_cacheIF.follower cpubus);
initial
  forever #1
   if(cpubus.valid)
    	begin
          if(cpubus.rw)
            $display("write data %h write addr %h", cpubus.wr_data, cpubus.addr);
    	cpubus.rd_data=32'hABCDEFAB;
          #5
          cpubus.ready=1'b1;
        end
endmodule

module CPU (cpu_cacheIF.leader cpubus);
  bit [31:0]x;
  initial 
  begin
  	cpubus.write({20'h0ABC,6'b000000,6'b000001}, 32'h00FEDC00);
    cpubus.read('1,x);
    $display("read val %h",x);
  end
endmodule
