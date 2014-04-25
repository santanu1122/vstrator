//
//  MemoryProfiling.h
//  VstratorCore
//
//  Created by akupr on 14.11.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <mach/mach.h>

vm_size_t usedMemory(void);
vm_size_t freeMemory(void);
void logMemUsage(void);
