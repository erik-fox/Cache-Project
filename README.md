# ECE 571 Group4_Cache_Controller
Designed a 4-way set associative cache with WB, Write Allocate  and employed Pseudo LRU replacement policy and verified the same.

Authors: 
- Durganila Anandhan (anandhan@pdx.edu)
- Erik Fox (erfox@pdx.edu)
- Manjari Rajasekharan(manjari@pdx.edu)
- Prem Sai Gudreddygari Chandra (premsai@pdx.edu)

Table of contents:

  - Description of files
  - Description of test cases
  - How to run main project


Description of files:

|-- cpu_cacheIFTB.sv                  		  "Verify cpu cache interface and TLM for CPU - MEM Access standalone"
	|-- cpu_cacheinterface.sv		  "Design of CPU Cache interface and task for read and write operation"
	|-- cpumod.sv				  "Design of CPU model and testcases of verifying cache controller"
|-- MemoryModel_TB.sv				  "TestBench for verifying Memory model standalone"
	|-- MemoryModel.sv			  "Design of Memory Model for verifying cache controller"
|-- dm_cache_dataTB.sv				  "Testbech for verify tag cache"
|-- dm_cache_tagTB.sv				  "Testbech for verify data cache"
	|-- cache_pkg.sv			  "Package definition for cache controller"
	|-- cache_controller.sv			  "Cache controller Design"
|-- mem_interface.sv				  "Cache Memory Interface"
|-- plru_hitTB.sv				  "Testbench to verify plur hit function"
	|-- plru_hit.sv				  "Function definition for plru hit computation"
|-- plru_evictTB.sv				  "Testbench to test plru eviction"
	|-- plru_evict.sv			  "Plru eviction design"
|-- top.sv					  "Top level module/ testbench for cache controller, CPU and Memory model"


- Description of testcases
	1. simple_rw: 				Issue continuous write and reads to all the words in the first cache line. Then, modify only a few words and ensure that only intended words are modified.
	2. cache_eviction: 			Issue five continuous writes to the same index which causes eviction of first access to the index. Then, read is issued to make sure the evicted cache is written back to memory and is possible to read.
	3. random_wr: 				Issue writes and reads with random data.
	4. random_addr_and_data:		Issue writes and reads with random data and address. This may cause access to non-existent memory regions, such access captured and flagged using assertions.
	5. constraint_random_addr_and_data:	Issue writes and reads to only addresses defined in memory with random data.
	6. cache_eviction_random:		Same as testcase 2 but, tag bits and offset are randomized and index kept the same

- How to run the main project:

1. Add the below files to the project:
	 cache_pkg.sv, cpu_cacheinterface.sv, cpumod.sv, mem_interface.sv, plru_evict.sv, plru_hit.sv, cache_controller.sv, MemoryModel.sv, top.sv

2. Compile:
	
	QuestaSim> vlog -sv cache_pkg.sv cpu_cacheinterface.sv cpumod.sv mem_interface.sv plru_evict.sv plru_hit.sv cache_controller.sv MemoryModel.sv top.sv

3. Simulation Example: 

	QuestaSim> vsim +TESTCASE=simple_rw work.top
	Note: +TESTCASE=<one of the above testcases>

4. Run
	VSIM 5> run -all
