//ECE571 Group Project: Cache Controller with CPU and memory interfaces

/*cache: data memory, single port, 256 blocks*/

`include "cache_pkg.sv"
`include "plru_hit.sv"
`include "plru_evict.sv"
`define   LRU_REPLACEMENT_POLICY 
`define   DEBUG_MODE  

PLRU lru = new(); // we will use this parent class object here for replacement


import cache_def ::*;
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

/*cache: tag memory, single port, 256 blocks*/
module dm_cache_tag(input bit clk, 
		    input cache_def::cache_req_type tag_req, 
    		    input cache_def::cache_tag_type tag_write,
    		    output cache_def::cache_tag_type tag_read[4]);

import cache_def::*; 
cache_tag_type tag_mem[64][4];

genvar i;
generate
	for (i=0;i<4;i++) begin
		always_comb
        	tag_read[i]= tag_mem[tag_req.index][i];
	end
endgenerate

always@(posedge(clk)) 
begin
	if (tag_req.we)
          	tag_mem[tag_req.index][tag_req.way]<=tag_write;
end
endmodule


/*cache finite state machine*/
module dm_cache_fsm(input clk, input rst, cpu_cacheIF.follower cpuBus, memoryIF.master memBus);

	timeunit 1ns;
	timeprecision 1ps;

  //import cache_def::*; //Importing packages

	/*write clock*/
	typedef enum {idle, compare_tag, allocate, write_back} cache_state_type;

	/*FSM state register*/
	cache_state_type vstate, rstate;
	/*interface signals to tag memory*/

	cache_tag_type tag_read[4]; //tag read result
	cache_tag_type tag_write; //tag write data
	cache_req_type tag_req; //tag request
	/*interface signals to cache data memory*/
	cache_lru_type lruState,lruNextState;
	cache_data_type data_read; //cache line read data
	cache_data_type data_write; //cache line write data
	cache_req_type data_req; //data req
	/*temporary variable for cache controler result*/
	cpu_result_type v_cpu_res;
	/*temporary variable for memory controller request*/
	mem_req_type v_mem_req;
        bit cache_miss_allocate;
	
	assign memBus.wr_data = v_mem_req.data;

	assign memBus.addr = v_mem_req.addr;
	assign memBus.rw = v_mem_req.rw;
	assign memBus.valid = v_mem_req.valid;

	assign cpuBus.rd_data = v_cpu_res.data;
	assign cpuBus.ready = v_cpu_res.ready;

	always_comb begin
		/*-------------------------default values for all signals------------*/
		/*no state change by default*/
		vstate = rstate;
		v_cpu_res = '{0, 0}; tag_write = '0;
		/*read tag by default*/
		tag_req.we='0;
		/*4-way map index for tag*/
		tag_req.index = cpuBus.addr[11:6];
		/*read current cache line by default*/
		data_req.we='0;
		/*4-way map index for cache data*/
		data_req.index = cpuBus.addr[11:6];
		/*modify correct word (32-bit) based on address*/
		data_write = data_read;
                
		case(cpuBus.addr[5:2])
			4'd0:data_write[31:0] = cpuBus.wr_data;
			4'd1:data_write[63:32] = cpuBus.wr_data;
			
			4'd2:data_write[95:64] = cpuBus.wr_data;
			4'd3:data_write[127:96] = cpuBus.wr_data;

			4'd4:data_write[159:128] = cpuBus.wr_data;
			4'd5:data_write[191:160] = cpuBus.wr_data;
			4'd6:data_write[223:192] = cpuBus.wr_data;
			4'd7:data_write[255:224] = cpuBus.wr_data;

			4'd8:data_write[287:256] = cpuBus.wr_data;
			4'd9:data_write[319:288] = cpuBus.wr_data;
			4'd10:data_write[351:320] = cpuBus.wr_data;
			4'd11:data_write[383:352] = cpuBus.wr_data;

			4'd12:data_write[415:384] = cpuBus.wr_data;
			4'd13:data_write[447:416] = cpuBus.wr_data;
			4'd14:data_write[479:448] = cpuBus.wr_data;
			4'd15:data_write[511:480] = cpuBus.wr_data;
		endcase

		/*read out correct word(32-bit) from cache (to CPU)*/
		case(cpuBus.addr[5:2])
			4'd0:v_cpu_res.data = data_read[31:0];
			4'd1:v_cpu_res.data = data_read[63:32];
			4'd2:v_cpu_res.data = data_read[95:64];
			4'd3:v_cpu_res.data = data_read[127:96];

			4'd4:v_cpu_res.data = data_read[159:128];
			4'd5:v_cpu_res.data = data_read[191:160];
			4'd6:v_cpu_res.data = data_read[223:192];
			4'd7:v_cpu_res.data = data_read[255:224];

			4'd8:v_cpu_res.data = data_read[287:256];
			4'd9:v_cpu_res.data = data_read[319:288];
			4'd10:v_cpu_res.data = data_read[351:320];
			4'd11:v_cpu_res.data = data_read[383:352];

			4'd12:v_cpu_res.data = data_read[415:384];
			4'd13:v_cpu_res.data = data_read[447:416];
			4'd14:v_cpu_res.data = data_read[479:448];
			4'd15:v_cpu_res.data = data_read[511:480];

		endcase
		/*memory request data (used in write)*/
		v_mem_req.data = data_read;
		/*memory request address (sampled from CPU request)*/
		//v_mem_req.addr = cpuBus.addr;
		//v_mem_req.rw='0;
		//------------------------------------Cache FSM-------------------------
		case(rstate)
		/*idle state*/
			idle : begin
			        v_mem_req.valid='0;
			        v_mem_req.rw='0;
		                /*memory request address (sampled from CPU request)*/
                                v_mem_req.addr = cpuBus.addr;
				/*If there is a CPU request, then compare cache tag*/
				cache_miss_allocate = '0;
                                 if (cpuBus.valid)
					vstate = compare_tag;

			end
			/*compare_tag state*/
			compare_tag : begin
			        v_mem_req.valid='0;
			        v_mem_req.rw='0;
		                /*memory request address (sampled from CPU request)*/
                                v_mem_req.addr = cpuBus.addr;
				/*cache hit (tag match and cache entry is valid)*/
				if (cpuBus.addr[TAGMSB:TAGLSB] == tag_read[0].tag && tag_read[0].valid) begin
					tag_req.way=2'b00;
					v_cpu_res.ready='1;
                                        data_req.way='d0;
					`ifdef LRU_REPLACEMENT_POLICY
					if (cache_miss_allocate == 1'b0) begin
						plru_hit(lruState,'d0,lruNextState);
					end
					`endif
					/*write hit*/
					if (cpuBus.rw) begin
						/*read/modify cache line*/
						tag_req.we='1; data_req.we='1;
						/*no change in tag*/
						tag_write.tag = tag_read[0].tag;
						tag_write.valid='1;
						/*cache line is dirty*/
						tag_write.dirty='1;
					end
															
					/*xaction is finished*/
					vstate = idle;
                                        `ifdef DEBUG_MODE
				          $display("Cache Hit at addr: %h", cpuBus.addr);
                                        `endif//  DEBUG_MODE
				end
				else if (cpuBus.addr[TAGMSB:TAGLSB] == tag_read[1].tag && tag_read[1].valid) begin
					tag_req.way=2'b01;
					v_cpu_res.ready='1;
                                        data_req.way='d1;
					`ifdef LRU_REPLACEMENT_POLICY
					if (cache_miss_allocate == 1'b0) begin
						plru_hit(lruState,'d1,lruNextState);
					end
					`endif
					/*write hit*/
					if (cpuBus.rw) begin
						/*read/modify cache line*/
						tag_req.we='1; data_req.we='1;
						/*no change in tag*/
						tag_write.tag = tag_read[1].tag;
						tag_write.valid='1;
						/*cache line is dirty*/
						tag_write.dirty='1;
					end

					/*xaction is finished*/
					vstate = idle;
                                        `ifdef DEBUG_MODE
					  $display("Cache Hit at addr: %h", cpuBus.addr);
                                        `endif//  DEBUG_MODE
				end
				else if (cpuBus.addr[TAGMSB:TAGLSB] == tag_read[2].tag && tag_read[2].valid) begin
					tag_req.way=2'b10;
					v_cpu_res.ready='1;
                    data_req.way='d2;
					`ifdef LRU_REPLACEMENT_POLICY
					if (cache_miss_allocate == 1'b0) begin
						plru_hit(lruState,'d2,lruNextState);
					end
					`endif
					/*write hit*/
					if (cpuBus.rw) begin
						/*read/modify cache line*/
						tag_req.we='1; data_req.we='1;
						/*no change in tag*/
						tag_write.tag = tag_read[2].tag;
						tag_write.valid='1;
						/*cache line is dirty*/
						tag_write.dirty='1;
					end

					/*xaction is finished*/
					vstate = idle;
                                        `ifdef DEBUG_MODE
					  $display("Cache Hit at addr: %h", cpuBus.addr);
                                        `endif//  DEBUG_MODE
				end
				else if (cpuBus.addr[TAGMSB:TAGLSB] == tag_read[3].tag && tag_read[3].valid) begin
					tag_req.way=2'b11;
					v_cpu_res.ready='1;
                                        data_req.way='d3;
					`ifdef LRU_REPLACEMENT_POLICY
					if (cache_miss_allocate == 1'b0) begin
						plru_hit(lruState,'d3,lruNextState);
					end
					`endif
					/*write hit*/
					if (cpuBus.rw) begin
						/*read/modify cache line*/
						tag_req.we='1; data_req.we='1;
						/*no change in tag*/
						tag_write.tag = tag_read[3].tag;
						tag_write.valid='1;
						/*cache line is dirty*/
						tag_write.dirty='1;
					end

					/*xaction is finished*/
					vstate = idle;
                                        `ifdef DEBUG_MODE
					  $display("Cache Hit at addr: %h", cpuBus.addr);
                                        `endif//  DEBUG_MODE
				end
				/*cache miss*/
				else begin
					/*generate new tag*/
					/*new tag*/
					tag_req.we='1;
				        tag_write.valid='1;
                                        if (cache_miss_allocate == 1'b0) begin
					  `ifdef LRU_REPLACEMENT_POLICY
						tag_req.way =lru.pseudolru_evict(lruState,lruNextState);
						data_req.way=tag_req.way;
					  `elsif
						tag_req.way = $urandom_range(0,3);
						data_req.way = tag_req.way;
					  `endif
                                        end
					tag_write.tag = cpuBus.addr[TAGMSB:TAGLSB];

					/*cache line is dirty if write*/
					tag_write.dirty = cpuBus.rw;
					
					/*generate memory request on miss*/
					v_mem_req.valid ='1;
					/*compulsory miss or miss with clean block*/
                    if (tag_read[tag_req.way].valid == 1'b0 || tag_read[tag_req.way].dirty == 1'b0) begin
						/*wait till a new block is allocated*/
						vstate = allocate;
                                                `ifdef DEBUG_MODE
						   $display("Cache compulsory miss or miss with clean block at addr: %h", cpuBus.addr);
                                                `endif//  DEBUG_MODE
                                             end
					else if (tag_read[tag_req.way].valid == 1'b1 && tag_read[tag_req.way].dirty == 1'b1) begin
						/*miss with dirty line*/
						/*write back address*/
						v_mem_req.addr = {tag_read[tag_req.way].tag, cpuBus.addr[TAGLSB-1:0]};
						v_mem_req.rw='1;
						/*wait till write is completed*/
						vstate = write_back;
					end
					else;

				end
			end
			/*wait for allocating a new cache line*/
			allocate: begin
				/*memory controller has responded*/
				if (memBus.ready) begin
					/*re-compare tag for write miss (need modify correct word)*/
                                        `ifdef DEBUG_MODE
					  $display("Re-compare tag for write miss and modify correct word of cache line at addr: %h", cpuBus.addr);
                                        `endif//  DEBUG_MODE
					vstate = compare_tag;
					data_write = memBus.rd_data;
					/*update cache line data*/
					data_req.we='1;
					v_mem_req.valid='0;
                                        cache_miss_allocate = '1;
				end
			end
			/*wait for writing back dirty cache line*/
			write_back : begin
                                `ifdef DEBUG_MODE
				   $display("Cache miss with dirty line, write back data at addr: %h", cpuBus.addr);
                                `endif//  DEBUG_MODE
				/*write back is completed*/
				if (memBus.ready) begin
					/*issue new memory request (allocating a new line)*/
					v_mem_req.valid='1;
					v_mem_req.rw='0;
		                        /*memory request address (sampled from CPU request)*/
                                        v_mem_req.addr = cpuBus.addr;

					vstate = allocate;
				end
			end
		endcase
	end
	always_ff @(posedge(clk)) begin
		if (rst)
			rstate <= idle; //reset to idle state
		else
			rstate <= vstate;
	end
	/*connect cache tag/data memory*/
	dm_cache_tag ctag(.*);
	dm_cache_data cdata(.*);
endmodule
