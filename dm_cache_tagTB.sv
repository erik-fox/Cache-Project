module dm_cache_tagTB();

	
  import cache_def::*;
  bit clock;
 
  cache_req_type tag_req;
  cache_tag_type tag_write; 
  cache_tag_type tag_read[4];

  
  
  dm_cache_tag c0(clock, tag_req, tag_write, tag_read);

  
initial
  begin
    $monitor("Tag0 %h Tag1 %h Tag2 %h Tag3 %h", tag_read[0],tag_read[2],tag_read[2],tag_read[3]);
    tag_req.index=6'b010101;
    tag_req.way='1;
   	tag_req.we=1'b1;
    tag_write.valid=1'b1;
    tag_write.dirty=1'b0;
    tag_write.tag='0;
    #100
    tag_req.we=1'b0;
    tag_write.valid={22{'1}};
    #100
    tag_req.way='0;
    tag_req.we=1'b1;
    tag_write={2{11'b11111111111}};
    #100
    tag_req.way='1;
    tag_req.we=1'b0;
    tag_write={22{'1}};

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

module dm_cache_tag(input bit clk, 
	input cache_def::cache_req_type tag_req, 
    input cache_def::cache_tag_type tag_write,
    output cache_def::cache_tag_type tag_read[4]);

	
	import cache_def::*; 
	
  	cache_tag_type tag_mem[64][4];

  	always_comb
      		foreach(tag_read[i])
        		tag_read[i]= tag_mem[tag_req.index][i];

	always@(posedge(clk)) begin
		if (tag_req.we)
          		tag_mem[tag_req.index][tag_req.way]<=tag_write;
	end
endmodule
