module dm_cache_dataTB();

	
  import cache_def::*;
  bit clock;
  cache_lru_type lruNextState; 
  cache_req_type data_req;
  cache_data_type data_write; 
  cache_data_type data_read;
  cache_lru_type lruState;
  
  
  dm_cache_data c0(clock, lruNextState, data_req, data_write, data_read, lruState);
  
initial
  begin
    data_req.index=6'b010101;
    data_req.way='1;
    data_req.we=1'b1;
    data_write='1;
    #100
    lruNextState='1;
    #100
    data_req.way='0;
    #100
    data_req.index='0;
    #100
    data_req.we='0;
    data_req.index='1;
  end

initial
begin
  	$dumpfile("dump.vcd"); $dumpvars;
	clock = 1'b0;
	forever #10 clock = ~clock;
end
initial
  begin
    
    #1000
    $finish;
  end
endmodule

module dm_cache_data(input bit clk, 
                     input cache_def::cache_lru_type lruNextState, 
                     input cache_def::cache_req_type data_req, 
                     input cache_def::cache_data_type data_write, 
                     output cache_def::cache_data_type data_read,
                     output cache_def::cache_lru_type lruState);

import cache_def::*; //Importing package

cache_lru_type lru_mem[64];
cache_data_type data_mem[64][4] ;

assign data_read = data_mem[data_req.index][data_req.way];
assign lruState = lru_mem[data_req.index];

always@(posedge(clk)) 
begin
  lru_mem[data_req.index]<=lruNextState;//index wont change until back to idle
	if (data_req.we)
			data_mem[data_req.index][data_req.way]<=data_write;
end
endmodule
