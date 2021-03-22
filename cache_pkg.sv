package cache_def;
   	timeunit 1ns;
	timeprecision 1ps;

	// data structures for cache tag & data
	parameter int TAGMSB = 31; //tag msb
	parameter int TAGLSB = 12; //tag lsb

	//data structure for cache tag
	typedef struct packed {
		bit valid; //valid bit
		bit dirty; //dirty bit
		bit [TAGMSB:TAGLSB]tag; //tag bits
	}cache_tag_type;
	//cache_tag_type cache_1;

	//data structure for cache memory request
	typedef struct {
		bit [5:0]index; //6-bit index
		bit [1:0]way;   //2-bit index
		bit we; //write enable
	}cache_req_type;
	//cache_req_type cache_2;

	//three bits for LRU
	typedef bit [2:0]cache_lru_type;
	//cache_lru_type cache_3;

	//512-bit cache line data
	typedef bit [511:0]cache_data_type;
	//cache_data_type cache_4;

        // data structures for CPU<->Cache controller interface
	// CPU request (CPU->cache controller)
	typedef struct {
		bit [31:0]addr; //32-bit request addr
		bit [31:0]data; //32-bit request data (used when write)
		bit rw; //request type : 0 = read, 1 = write
		bit valid; //request is valid
	}cpu_req_type;
	//cpu_req_type cpu_1;

	// Cache result (cache controller->cpu)
	typedef struct {
		bit [31:0]data; //32-bit data
		bit ready; //result is ready
	}cpu_result_type;
	//cpu_result_type cpu_2;

	//----------------------------------------------------------------------
	// data structures for cache controller<->memory interface
	// memory request (cache controller->memory)
	typedef struct {
		bit [31:0]addr; //request byte addr
		bit [511:0]data; //128-bit request data (used when write)
		bit rw; //request type : 0 = read, 1 = write
		bit valid; //request is valid
	}mem_req_type;
	//mem_req_type mem_1;

	// memory controller response (memory -> cache controller)
	typedef struct {
		cache_data_type data; //128-bit read back data
		bit ready; //data is ready
	}mem_data_type;
	//mem_data_type mem_2;
endpackage
