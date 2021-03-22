
module MemoryModel #(
   parameter tCL  =1,
   parameter tRCD = 1,
   parameter BURST = 8,
   parameter Lo=32'd0,
   parameter Hi=32'd15359

   )(memoryIF.slave memBus);

logic [63:0]  Mem[Hi:Lo]; // default 120KiB memory, single rank with x4 chips.
logic [63:0] data_write [8];
logic [63:0] data_read [8];

logic memDataAvail = 0;
logic ld_addr, rd_ld_data, wr_ld_data;
logic [31:0] AddrReg;


enum {IDLE, READ, WRITE, RESPOND} State, NextState;


initial
    begin
    for (int i = 0; i < 15360; i++)
        Mem[i] <= 0;
    end

    
always_ff @(posedge memBus.clk)
    if (ld_addr) AddrReg <= memBus.addr;
    
always_ff @(posedge memBus.clk, posedge memBus.rst)
begin
  if (memBus.rst) State <= IDLE;
  else State <= NextState;
 end
 
 always_comb begin
    if ( wr_ld_data) begin
		data_write[0] = memBus.wr_data[63:0];
		data_write[1] = memBus.wr_data[127:64];
		data_write[2] = memBus.wr_data[191:128];
		data_write[3] = memBus.wr_data[255:192];
		data_write[4] = memBus.wr_data[319:256];
		data_write[5] = memBus.wr_data[383:320];
		data_write[6] = memBus.wr_data[447:384];
		data_write[7] = memBus.wr_data[511:448];
	end
 end
 
  always_comb begin
     if (rd_ld_data) begin
		    memBus.rd_data[63:0]   = data_read[0];
			memBus.rd_data[127:64] = data_read[1];
			memBus.rd_data[191:128]= data_read[2];
			memBus.rd_data[255:192]= data_read[3];
			memBus.rd_data[319:256]= data_read[4];
			memBus.rd_data[383:320]= data_read[5];
			memBus.rd_data[447:384]= data_read[6];
			memBus.rd_data[511:448]= data_read[7];
                        
                     end
 end
always_comb
    begin
     NextState = State;
     ld_addr    = '0;
     wr_ld_data = '0;
     rd_ld_data = '0;
	 memBus.ready = '0;
    case (State)
    IDLE: 	begin
			ld_addr =  (memBus.valid)? 1 : 0;
			NextState = (~memBus.valid)? IDLE : ((memBus.rw)? WRITE: READ);
			end
	READ: 	begin
			if (memDataAvail)
             			NextState = RESPOND;	
			end
	WRITE: 	begin
			wr_ld_data = '1;
			if (memDataAvail)
             NextState = RESPOND;
			end
	RESPOND: begin   
			 memBus.ready = '1;
             rd_ld_data = '1;
             NextState = IDLE;
			end
    endcase
    end
    
    int i;
    int mem_addr;


 always @(State)
    begin
    bit [2:0] delay;
    memDataAvail = 0;
    if (State == READ)
    	begin
    	delay = (tCL + tRCD)*2;
    	
        repeat (delay) @(posedge memBus.clk);
      
        i = 0;
        mem_addr = {AddrReg[31:6],6'b000000}/8;
        $display("Read request to Memory at addr: %h", memBus.addr);
        
        ReadAddressCheck:assert (mem_addr >= Lo && mem_addr <= Hi) else  $warning ("Physical memory location %h doesn't exist",mem_addr );
        
        repeat (BURST) @(posedge memBus.clk or negedge memBus.clk) begin //8 times -64bit data: 512 cache line
                  data_read[i] = Mem[mem_addr];
                  i = i + 1;
                  mem_addr = mem_addr + 1;
        end
        memDataAvail = 1;
	//	$display("Value read from Address");
    	end

    if (State == WRITE)
    	begin
    	delay = (tCL + tRCD )*2;
    	
        repeat (delay) @(posedge memBus.clk);
        i = 0;
        mem_addr = {AddrReg[31:6],6'b000000}/8;
        $display("Write request to Memory at addr: %h", memBus.addr);
		
        WriteAddressCheck:assert (mem_addr >= Lo && mem_addr <= Hi) else  $warning ("Physical memory location %h doesn't exist",mem_addr );
        
        repeat (BURST) @(posedge memBus.clk or negedge memBus.clk) begin
                  Mem[mem_addr] = data_write[i] ;
                  i = i +1;
                  mem_addr = mem_addr + 1;
        end
        memDataAvail = 1;
	//	$display("Value read from Address");
    	end       
    end
    
	
endmodule






