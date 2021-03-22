// Code your design here
 /* pseudo-LRU

 Access:
 1=Left, 0=Right

 Replacement:
 1=Right, 0=Left

 */

 //import cache_def ::*;

 class PLRU; // parent class

 function logic [1:0] pseudolru_evict (input bit [2:0] lruState, output bit [2:0] lruNextState);
 logic [1:0] way;
 casez(lruState)
 	3'b?00: begin
 			way=0;
 	 		lruNextState={lruState[2],2'b11};
 		end
 	3'b?10: begin
 			way=1;
     			lruNextState={lruState[2],2'b01};
 		end
 	3'b0?1: begin
 			way=2;
     			lruNextState={1'b1,lruState[1],1'b0};
 		end
 	3'b1?1: begin
 			way=3;
 			lruNextState={1'b0,lruState[1],1'b0};
 		end	
endcase	

return way;
 
endfunction

 endclass
