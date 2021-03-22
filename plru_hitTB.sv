module plru_hitTB();
bit	[1:0] way;
bit [2:0] lruState, lruNextState;
 
initial
begin
  	$dumpfile("dump.vcd"); $dumpvars;
  for(int i=0; i<32;i++)
    begin
      #10
      {lruState,way}=i;
      plru_hit(lruState,way,lruNextState);
      $display("lruState     %b  Way    %b",lruState, way);
      $display("lruNextState %b", lruNextState);
    end
end
endmodule
