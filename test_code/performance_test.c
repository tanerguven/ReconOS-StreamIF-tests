#include "reconos.h"
#include "mbox.h"

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <assert.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <limits.h>
#include <string.h>
#include "timing.h"

#include <sys/types.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/time.h>

unsigned int* malloc_page_aligned(unsigned int pages);
void print_mmu_stats();
void generate_data( unsigned int *array, unsigned int size );

void * map_memory(uint32_t address, uint32_t address_length);
int unmap_memory(volatile void *addr, uint32_t address_length);
void print_help(const char * programName);

// void cache_flush();

// 64 mb read && 64 mb write address
#define RAM_MM2S 0x14000000
#define RAM_S2MM 0x10000000
#define MAX_RAM_ADDRESS_LENGTH 0x04000000
#define RAM_ADDRESS_LENGTH 0x01000000

#define PAGE_SIZE 4096
#define PAGE_WORDS 1024
#define PAGE_MASK 0xFFFFF000
int BLOCK_SIZE = 0;

#define TO_WORDS(x) ((x)/4)
#define TO_PAGES(x) ((x)/PAGE_SIZE)
#define TO_BLOCKS(x) ((x)/(BLOCK_SIZE))

// hardware threads
struct reconos_resource res[2];
struct reconos_hwt hwt[8];
// mailboxes
struct mbox mb_start;
struct mbox mb_stop;

// read & write addresss for burst
uint32_t addr_ptr[256][3];

// total test size per HWT
unsigned long test_total_size;

int ro_error_count = 0;

double run_test(int buffer_size, int repeat_count, int test_mode, int ro_test_xor) {
	timing_t t_start, t_stop;
	ms_t t_test;
	int i, j;

	int ret_xor = 0;

	// Start sort threads
	t_start = gettime();

	for ( j = 0 ; j < repeat_count ; j++) {
		for (i=0; i<TO_BLOCKS(buffer_size); i++) {
			mbox_put(&mb_start,(unsigned int)addr_ptr[i]);
		}
		for (i=0; i<TO_BLOCKS(buffer_size); i++) {
			int ret = mbox_get(&mb_stop);
			ret_xor ^= ret;
		}
	}

	t_stop = gettime();
	t_test = calc_timediff_ms(t_start,t_stop);

	if (test_mode == 1 && ret_xor != ro_test_xor)
		ro_error_count++;

	double speed_mb_s = test_total_size / ((double)t_test/1000);
	return speed_mb_s;
}

void print_help(const char * programName ) {
	printf("usage: %s HWT_COUNT streamif/memif BLOCK_SIZE BUFFER_SIZE TEST_COUNT\n", programName);
	printf("exmaple usage: %s 2 streamif 2 1\n", programName);
}

int main(int argc, char ** argv) {
	int i;
	int hw_threads;
	int running_threads;
	int buffer_size;
	unsigned int *data, *data_write, *copy;
	int test_ro, test_wo, test_streamif, test_memif;

	int test_repeat_count = 256;


	if ((argc < 4) || (argc > 5)) {
		print_help(argv[0]);
		exit(1);
	}

	hw_threads = atoi(argv[1]);
	test_streamif = (strncmp(argv[2], "streamif", strlen("streamif")) == 0);
	test_memif = (strncmp(argv[2], "memif", strlen("memif")) == 0);
	test_ro = (strcmp(argv[2]+strlen(argv[2])-2, "-r") == 0);
	test_wo = (strcmp(argv[2]+strlen(argv[2])-2, "-w") == 0);
	int test_mode;
	if (!test_streamif && !test_memif) {
		printf("error, test name\n");
		return -1;
	}

	if (test_ro)
		test_mode = 1;
	else if (test_wo)
		test_mode = 2;
	else
		test_mode = 0;

	BLOCK_SIZE = atoi(argv[3]);
	i = strlen(argv[3]);
	if (argv[3][i-1] == 'K')
		BLOCK_SIZE *= 1024;

	if (BLOCK_SIZE % (PAGE_SIZE*2) != 0) {
		printf("ERROR: BLOCK_SIZE %% %d != 0\n", PAGE_SIZE*2);
		return -1;
	}

	buffer_size = hw_threads*BLOCK_SIZE;

	assert(TO_BLOCKS(buffer_size) <= 256);

	int test_count = 1;
	if (argc > 4)
		test_count = atoi(argv[4]);

	assert(test_count > 0 && test_count < 100);

	if (test_ro)
		printf("readonly test\n");
	if (test_wo)
		printf("writeonly test\n");

	if (test_streamif)
		printf("streamif test\n");
	if (test_memif)
		printf("memif test\n");

	printf("block size: %d kb\n", BLOCK_SIZE/1024);
	printf("test count: %d\n", test_count);

	assert(buffer_size <= MAX_RAM_ADDRESS_LENGTH);

	running_threads = hw_threads;


	// init mailboxes
	mbox_init(&mb_start,16);
	mbox_init(&mb_stop ,16);

	// init reconos and communication resources
	reconos_init();

	res[0].type = RECONOS_RESOURCE_TYPE_MBOX;
	res[0].ptr  = &mb_start;
	res[1].type = RECONOS_RESOURCE_TYPE_MBOX;
	res[1].ptr  = &mb_stop;

	printf("Creating %i hw-threads: ", hw_threads);
	fflush(stdout);
	for (i = 0; i < hw_threads; i++) {
		printf(" %i",i);fflush(stdout);
		reconos_hwt_setresources(&(hwt[i]),res,2);
		reconos_hwt_create(&(hwt[i]),i,NULL);
	}
	printf("\n");



	//print_mmu_stats();
	// create pages and generate data
	if (test_streamif) {
		data = (unsigned int*)map_memory(RAM_MM2S, buffer_size);
		printf("read : 0x%x - 0x%x\n", RAM_MM2S, RAM_MM2S+buffer_size);
		data_write = (unsigned int*)map_memory(RAM_S2MM, buffer_size);
		printf("write : 0x%x - 0x%x\n", RAM_S2MM, RAM_S2MM+buffer_size);
		copy = malloc(buffer_size);
	} else {
		data = malloc_page_aligned(TO_PAGES(buffer_size));
		data_write = malloc_page_aligned(TO_PAGES(buffer_size));
		copy = malloc_page_aligned(TO_PAGES(buffer_size));
	}
	generate_data( data, TO_WORDS(buffer_size));

	// set write_data and calculate output
	int readonly_test_xor = 0;
	for (i = 0 ; i < TO_WORDS(buffer_size) ; i++) {
		data_write[i] = -1;
		readonly_test_xor ^= data[i];
	}

	memcpy(copy,data,TO_WORDS(buffer_size)*4);

	for (i=0; i<TO_BLOCKS(buffer_size); i++) {
		if (test_streamif) {
			int burst_count = BLOCK_SIZE/1024;
			addr_ptr[i][0] = ((test_mode & 0xf)<<16) | (burst_count & 0x3fff);
			addr_ptr[i][1] = (uint32_t)(RAM_S2MM + (i*BLOCK_SIZE));
			addr_ptr[i][2] = (uint32_t)(RAM_MM2S + (i*BLOCK_SIZE));
		} else {
			int burst_count = BLOCK_SIZE / (512*4);
			addr_ptr[i][0] = ((test_mode & 0xf)<<16) | (burst_count & 0x3fff);
			addr_ptr[i][1] = ((uint32_t)data_write)+(i*BLOCK_SIZE);
			addr_ptr[i][2] = ((uint32_t)data)+(i*BLOCK_SIZE);
		}
	}

	// run_test
	test_total_size = test_repeat_count * (buffer_size/1024) /1024;
	if (!test_ro && !test_wo)
		test_total_size *= 2;  // 2 : read+write

	double speed_sum = 0;
	for (i = 0 ; i < test_count ; i++) {
		speed_sum += run_test(buffer_size, test_repeat_count, test_mode, readonly_test_xor);
	}
	// average_speed = speed_sum / test_count;


	reconos_cache_flush();
	// cache_flush(); // not required

	// check
	if (test_mode == 0) { // rw
		int error_count = 0;
		for (i = 0 ; i < TO_WORDS(buffer_size) ; i++) {
			if (data[i] != copy[i]) {
				error_count++;
				if (error_count < 8)
					printf("data[%d] != copy[%d] (%d != %d)\n", i, i, data[i], copy[i]);
			}
			if (data_write[i] != data[i]) {
				error_count++;
				if (error_count < 8)
					printf("data_write[%d] != copy[%d] (%d != %d)\n", i, i, data_write[i], data[i]);
			}
		}
		if (error_count == 0)
			printf("CORRECT\n");
		else
			printf("ERROR COUNT : %d\n", error_count);

	} else if (test_mode == 1) { // readonly
		if (ro_error_count == 0)
			printf("CORRECT\n");
		else
			printf("test_ro error count: %d\n", ro_error_count);
	} else if (test_mode == 2) { // writeonly
		int error_count = 0;
		int value = 0;
		for (i = 0 ; i < TO_WORDS(buffer_size) ; i++) {
			if (i % TO_WORDS(BLOCK_SIZE) == 0)
				value = 0;

			if (data_write[i] != value) {
				error_count++;
				if (error_count < 8)
					printf("data[%d] != %d (%d)\n", i, value, data_write[i]);
			}
			value++;
		}
		if (error_count == 0)
			printf("CORRECT\n");
		else
			printf("ERROR COUNT : %d\n", error_count);
	}

	// terminate all threads
	printf("Sending terminate message to %i threads:", running_threads);
	fflush(stdout);
	for (i = 0; i < running_threads; i++) {
		printf(" %i",i);fflush(stdout);
		mbox_put(&mb_start,UINT_MAX);
	}
	printf("\n");

	printf("Waiting for termination...\n");
	for (i = 0; i < hw_threads; i++) {
		pthread_join(hwt[i].delegate,NULL);
	}

	// printf("\n");
	// print_mmu_stats();

	printf("\n");
	printf("hwt count: %d\n", hw_threads);
	printf("test size: %ld mb\n", test_total_size);
	printf("test count : %d\n", test_count);
	printf("speed : %.2f mb/s\n", speed_sum / test_count );

	//free(data);

	return 0;
}


unsigned int* malloc_page_aligned(unsigned int pages) {
	unsigned int * temp = malloc ((pages+1)*PAGE_SIZE);
	unsigned int * data = (unsigned int*)(((unsigned int)temp / PAGE_SIZE + 1) * PAGE_SIZE);
	printf("[malloc_page_aligned] %x - %x\n", (uint32_t)data, ((uint32_t)data) + pages*PAGE_SIZE);
	return data;
}


void print_mmu_stats() {
	int hits,misses,pgfaults;

	reconos_mmu_stats(&hits,&misses,&pgfaults);

	printf("MMU stats: TLB hits: %d    TLB misses: %d    page faults: %d\n",hits,misses,pgfaults);
}

int FD_MEM = -1;

void * map_memory(uint32_t address, uint32_t address_length) {
	if (FD_MEM == -1) {
		FD_MEM = open("/dev/mem",  O_RDWR | O_SYNC);
		if (FD_MEM < 0) {
			printf("open /dev/mem failed");
			exit(1);
		}
	}
	// UYARI: MAP_PRIVATE calismiyor (deger ilk yazildiginda dogru okunuyor, belli bir sure sonra kendi kendine sifirlaniyor)
	void * addr = mmap(NULL, address_length, PROT_READ|PROT_WRITE, MAP_SHARED, FD_MEM, address);

	/* printf("[map_memory] %x -> %x  (size:%d kb)\n", address, (uint32_t)addr, address_length/1024); */

	return addr;
}

int unmap_memory(volatile void *addr, uint32_t address_length) {
	return munmap((void*)addr, address_length);
}

void cache_flush() {
	printf("cache flush\n");
	int count = 16*1024*1024;
	uint32_t * data = malloc(count*sizeof(int));
	int i;
	for (i = 0 ; i < count ; i++) {
		data[i] = i;
	}
	free(data);
	printf("cache flush end\n");
}

// generates an array of random values
void generate_data( unsigned int *array, unsigned int size ) {
    unsigned int i;

    //srandom( time( 0 ) );
    for ( i = 0; i < size; i++ ) {
        array[i] = 1000+(size-i-1); //( unsigned int ) random(  );
    }
}
