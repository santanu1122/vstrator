//
//  MemoryProfiling.m
//  VstratorCore
//
//  Created by akupr on 14.11.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "MemoryProfiling.h"

//#define DEBUG_MEMORY

static const long MemoryDiff = 1024l * 1024l; // 1M

vm_size_t usedMemory(void) {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    return (kerr == KERN_SUCCESS) ? info.resident_size : 0; // size in bytes
}

vm_size_t freeMemory(void) {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t pagesize;
    vm_statistics_data_t vm_stat;
    
    host_page_size(host_port, &pagesize);
    (void) host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    return vm_stat.free_count * pagesize;
}

void logMemUsage(void) {
#ifdef DEBUG_MEMORY
    // compute memory usage and log if different by >= MemoryDiff
    static long prevMemUsage = 0;
    long curMemUsage = usedMemory();
    long memUsageDiff = curMemUsage - prevMemUsage;
    
    if (memUsageDiff > MemoryDiff || memUsageDiff < -MemoryDiff) {
        prevMemUsage = curMemUsage;
        NSLog(@"Memory used %7.1f (%+5.0f), free %7.1f kb", curMemUsage/1024.0f, memUsageDiff/1024.0f, freeMemory()/1024.0f);
    }
#endif
}