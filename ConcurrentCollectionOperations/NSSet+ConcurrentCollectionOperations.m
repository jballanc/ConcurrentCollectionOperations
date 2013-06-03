//
//  NSSet+ConcurrentCollectionOperations.m
//  ConcurrentCollectionOperations
//
//  Created by Dave Lee on 2013-06-02.
//  Copyright (c) 2013 Internet. All rights reserved.
//

#import "NSSet+ConcurrentCollectionOperations.h"

@implementation NSSet (ConcurrentCollectionOperations)

- (instancetype)cco_concurrentMap:(CCOMapBlock)mapBlock {
    NSParameterAssert(mapBlock != nil);

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    return [self cco_concurrentWithQueue:queue map:mapBlock];
}

- (instancetype)cco_concurrentWithQueue:(dispatch_queue_t)queue map:(CCOMapBlock)mapBlock {
    NSParameterAssert(mapBlock != nil);

    NSArray *objects = [self allObjects];

    __strong id *mapped = (__strong id*)calloc(self.count, sizeof(id));
    dispatch_apply(self.count, queue, ^(size_t i) {
        mapped[i] = mapBlock(objects[i]);
    });

    NSSet *result = [NSSet setWithObjects:mapped count:self.count];

    free(mapped);
    return result;
}

- (instancetype)cco_concurrentFilter:(CCOPredicateBlock)predicateBlock {
    NSParameterAssert(predicateBlock != nil);

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    return [self cco_concurrentWithQueue:queue filter:predicateBlock];
}

- (instancetype)cco_concurrentWithQueue:(dispatch_queue_t)queue filter:(CCOPredicateBlock)predicateBlock {
    NSParameterAssert(predicateBlock != nil);

    NSArray *objects = [self allObjects];
    __unsafe_unretained id *filtered = (__unsafe_unretained id *)calloc(self.count, sizeof(id));
    [objects getObjects:filtered];

    __block NSUInteger filteredCount = 0;
    dispatch_apply(self.count, queue, ^(size_t i) {
        if (predicateBlock(filtered[i])) {
            ++filteredCount;
        } else {
            filtered[i] = nil;
        }
    });

    NSMutableSet *result = [NSMutableSet setWithCapacity:filteredCount];
    for (NSUInteger i = 0; i < self.count; ++i) {
        if (filtered[i] != nil) {
            [result addObject:filtered[i]];
        }
    }

    free(filtered);
    return result;
}

@end
