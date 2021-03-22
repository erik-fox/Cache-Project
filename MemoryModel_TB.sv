module MemoryModel_TB();
timeunit 1ns; timeprecision 1ps;
bit clk = '1, rst= '1;
always #5 clk = ~clk;

memoryIF i_memBus(.clk(clk), .rst(rst));
MemoryModel M1( .memBus(i_memBus));

initial begin
integer i;
logic [511:0] mem_data_var;
logic [511:0] mem_rdata;
logic [511:0]write_data_list[$];
#2 rst = '0;
//repeat (2) @(posedge i_memBus.clk);

$display("Test case :Consecutive read-write operation starting from base address 0 to Max");
i_memBus.rw ='1; 
$display("Write");
for(i = 0; i <1024; i = i+64) begin
        i_memBus.addr =i;i_memBus.valid = '1;
        @(posedge clk) i_memBus.valid = '0;
	mem_data_var = $random;
	i_memBus.wr_data = mem_data_var;
	write_data_list.push_back(mem_data_var);
	wait (i_memBus.ready == '1);
	repeat (2) @(negedge clk);
	
end

i_memBus.valid = '0;i_memBus.rw ='0;
#40
@(posedge clk);
$display("Read");
i_memBus.rw ='0; 
for(i = 0; i <1024; i =i+64) begin
	i_memBus.addr =i;i_memBus.valid = '1;
        @(posedge clk) i_memBus.valid = '0;
	wait (i_memBus.ready == '1);
        mem_rdata = i_memBus.rd_data ;
        mem_data_var = write_data_list.pop_front();
	Readcheck0: assert (mem_rdata === mem_data_var ) $display ("OK. Read Data equals Write Data");
                                  else  $error ("Data Mismatch at %h: Read Data = %h, Expected Data = %h", i,mem_rdata,mem_data_var);
	repeat (2) @(posedge clk);
end

$finish;
end


endmodule
