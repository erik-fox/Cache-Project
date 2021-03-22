function void plru_hit (input bit[2:0]lruState, input bit[1:0] way_accessed,output bit [2:0]lruNextState);
case(way_accessed)
	2'b00: lruNextState = {lruState[2],2'b11};
    2'b01: lruNextState = {lruState[2],2'b01};
    2'b10: lruNextState = {1'b1,lruState[1],1'b0};
    2'b11: lruNextState = {1'b0,lruState[1],1'b0};
endcase
endfunction
