module plru_evictTB();

logic [1:0] way;
bit [2:0] lruState, lruNextState;
 
initial
begin
  	$dumpfile("dump.vcd"); $dumpvars;
  for(int i=0; i<8;i++)
    begin
      #10
      lruState=i;
      way=pseudolru_evict(lruState,lruNextState);
      $display("lruState     %b",lruState);
      $display("lruNextState %b", lruNextState);
      $display("Way          %d",way);
    end
end
endmodule
