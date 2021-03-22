module CPU #(
   parameter Lo=32'd0,
   parameter Hi=32'd15359

   )(cpu_cacheIF.leader cpubus);
	timeunit 1ns; timeprecision 1ps;
	

	bit [31:0] rd_data,mem_data_var,mem_addr_var;

        integer i;
        string TESTCASE;
        logic [31:0]write_data_list[$];
        logic [31:0]write_addr_list[$];

        logic [5:0] offset_1,offset_2,offset_3, offset_4, offset_5 ;
        logic [5:0] index;
        logic [12:0]tag_1, tag_2, tag_3, tag_4, tag_5;
initial
begin
      if($value$plusargs("TESTCASE=%s", TESTCASE))
	 $display($time," TESTCASE: %d", TESTCASE);
      else 
         $display($time," Provide plusarg TESTCASE = simple_rw or cache_evition or random_wr or random_addr_and_data or constraint_random_addr_and_data or cache_eviction_random ");
            
         
       repeat (2) @(cpubus.clk);
       if (TESTCASE == "simple_rw") begin
             $display ("Test case: Accessing all words in First cache line and verify complusory miss and consecutive cache HIT");
             // Compulsary Miss
             for (i =0 ; i<63; i = i+4) begin 
                   @(posedge cpubus.clk);
                   cpubus.write(i, (32'h0F0F0000 + i));
             end
             // Hit
             for (i =0 ; i<63; i = i+4) begin
                   @(posedge cpubus.clk);
                   cpubus.read (i,rd_data);
                   Readcheck0: assert (rd_data === (32'h0F0F0000 + i)) $display ("OK. Read Data equals Write Data");
                                  else  $error ("Data Mismatch: Read Data = %h, Expected Data = %h", rd_data,(32'h0F0F0000 + i) );
             end
             //
             for (i =0 ; i<10; i = i+4) begin 
                   @(posedge cpubus.clk);
                   cpubus.write(i, (32'hABCD0000 + i));
             end
             //HIT
             for (i =0 ; i<10; i = i+4) begin
                   @(posedge cpubus.clk);
                   cpubus.read (i,rd_data);
                   Readcheck1: assert (rd_data === (32'hABCD0000 + i)) $display ("OK. Read Data equals Write Data");
                                  else  $error ("Data Mismatch: Read Data = %h, Expected Data = %h", rd_data,(32'hABCD0000 + i) );
             end
             //HIT
             for (i =12 ; i<63; i = i+4) begin
                   @(posedge cpubus.clk);
                   cpubus.read (i,rd_data);
                   Readcheck2: assert (rd_data === (32'h0F0F0000 + i)) $display ("OK. Read Data equals Write Data");
                                  else  $error ("Data Mismatch: Read Data = %h, Expected Data = %h", rd_data,(32'h0F0F0000 + i) );
             end
             
       end
      else if (TESTCASE == "cache_eviction") begin
            $display ("Test case: Accessing 4 consecutive cache lines within a set and creating scenario for eviction");
            cpubus.write({20'h0001,6'b000000,6'b010000}, 32'h00FEDC00);
            cpubus.write({20'h0002,6'b000000,6'b010000}, 32'h000CAAB0);
            cpubus.write({20'h0003,6'b000000,6'b010000}, 32'h0DAAA000);
            cpubus.write({20'h0004,6'b000000,6'b010000}, 32'h0FFFFF00);
            cpubus.write({20'h0005,6'b000000,6'b010000}, 32'hEEEEEE0D);
            cpubus.read({20'h0001,6'b000000,6'b010000}, rd_data);
            Readcheck3: assert (rd_data === 32'h00FEDC00)  $display ("OK. Read Data equals Write Data");
                           else  $error ("Data Mismatch: Read Data = %h, Expected Data = %h", rd_data, 32'h00FEDC00 );
      end
      else if (TESTCASE == "random_wr") begin
            $display("Test case :Consecutive read-write operation with random data");
            $display("Write");
            for(i = 0; i <1024; i = i+64) begin
            	mem_data_var = $random;
            	write_data_list.push_back(mem_data_var);
                //@(posedge cpubus.clk);
            	cpubus.write(i,mem_data_var) ;
            end
            repeat (5) @(posedge cpubus.clk);
            $display("Read");
            for(i = 0; i <1024; i =i+64) begin
               // @(posedge cpubus.clk);
                cpubus.read(i, rd_data);
                mem_data_var = write_data_list.pop_front();
            	Readcheck4: assert (rd_data === mem_data_var ) $display ("OK. Read Data equals Write Data");
                                              else  $error ("Data Mismatch at %h: Read Data = %h, Expected Data = %h", i, rd_data,mem_data_var);
            end
      end   
      else if (TESTCASE == "random_addr_and_data") begin
            $display("Test case :Consecutive read-write operation with random data");
            $display("Write");
            for(i = 0; i <64; i = i+1) begin
            	mem_data_var = $random;
            	mem_addr_var = $random;
            	write_data_list.push_back(mem_data_var);
            	write_addr_list.push_back(mem_addr_var);
            	cpubus.write(mem_addr_var,mem_data_var) ;
            end
            repeat (5) @(posedge cpubus.clk);
            $display("Read");
            for(i = 0; i <64; i =i+1) begin
                mem_addr_var = write_addr_list.pop_front();
                cpubus.read(mem_addr_var, rd_data);
                mem_data_var = write_data_list.pop_front();
            	Readcheck5: assert (rd_data === mem_data_var ) $display ("OK. Read Data equals Write Data");
                                              else  $error ("Data Mismatch at %h: Read Data = %h, Expected Data = %h", mem_addr_var, rd_data,mem_data_var);
            end
      end   
      else if (TESTCASE == "constraint_random_addr_and_data") begin
            $display("Test case :Consecutive read-write operation with random data");
            $display("Write");
            for(i = 0; i <64; i = i+1) begin
            	mem_data_var = $random;
            	mem_addr_var = $urandom_range(Lo,Hi);
            	write_data_list.push_back(mem_data_var);
            	write_addr_list.push_back(mem_addr_var);
            	cpubus.write(mem_addr_var,mem_data_var) ;
            end
            repeat (5) @(posedge cpubus.clk);
            $display("Read");
            for(i = 0; i <64; i =i+1) begin
                mem_addr_var = write_addr_list.pop_front();
                cpubus.read(mem_addr_var, rd_data);
                mem_data_var = write_data_list.pop_front();
            	Readcheck6: assert (rd_data === mem_data_var ) $display ("OK. Read Data equals Write Data");
                                              else  $error ("Data Mismatch at %h: Read Data = %h, Expected Data = %h", mem_addr_var, rd_data,mem_data_var);
            end
      end   
      else if (TESTCASE == "cache_eviction_random") begin
            $display ("Test case: Accessing different cache lines and creating scenario for eviction");
            for(i = 0; i <10; i =i+1) begin
                offset_1 = $random;
                offset_2 = $random;
                offset_3 = $random;
                offset_4 = $random;
                offset_5 = $random;
                index  = $urandom_range(0,63);
                tag_1  = $urandom_range(0,5);
                tag_2  = $urandom_range(6,10);
                tag_3  = $urandom_range(11,15);
                tag_4  = $urandom_range(16,20);
                tag_5  = $urandom_range(20,25);
                
                cpubus.write({tag_1,index,offset_1}, 32'hAAAAAAAA);
                cpubus.write({tag_2,index,offset_1}, 32'hBBBBBBBB);
                cpubus.write({tag_3,index,offset_1}, 32'hCCCCCCCC);
                cpubus.write({tag_4,index,offset_1}, 32'hDDDDDDDD);
                cpubus.write({tag_5,index,offset_5}, 32'hEEEEEEEE);
                cpubus.read({tag_1,index,offset_1}, rd_data);
                Readcheck7: assert (rd_data === 32'hAAAAAAAA)  $display ("OK. Read Data equals Write Data");
                               else  $error ("Data Mismatch: Read Data = %h, Expected Data = %h", rd_data, 32'hAAAAAAAA );
            end
      end
      else $display("Invalid value for plusarg TESTCASE, valid value is simple_rw or cache_evition or random_wr or random_addr_and_data or constraint_random_addr_and_data or cache_eviction_random");
      #50       $finish;
end  

endmodule
