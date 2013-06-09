//
//  NSOrderedSet+ConcurrentCollectionOperations.m
//  ConcurrentCollectionOperations
//
//  Created by Dave Lee on 2013-06-09.
//

#import "NSOrderedSet+ConcurrentCollectionOperations.h"

@implementation NSOrderedSet (ConcurrentCollectionOperations)

- (NSOrderedSet *)cco_concurrentMap:(CCOMapBlock)mapBlock {
    NSParameterAssert(mapBlock != nil);

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    return [self cco_concurrentWithQueue:queue map:mapBlock];
}

- (NSOrderedSet *)cco_concurrentWithQueue:(dispatch_queue_t)queue map:(CCOMapBlock)mapBlock {
    NSParameterAssert(mapBlock != nil);

    NSOrderedSet *snapshot = [self copy];

    void *pointers = calloc(snapshot.count, sizeof(id));
    __unsafe_unretained id *objects = (__unsafe_unretained id *)pointers;
    [snapshot getObjects:objects range:NSMakeRange(0, snapshot.count)];
    __strong id *mapped = (__strong id*)pointers;

    dispatch_apply(snapshot.count, queue, ^(size_t i) {
        mapped[i] = mapBlock(objects[i]);
    });

    NSOrderedSet *result = [NSOrderedSet orderedSetWithObjects:mapped count:snapshot.count];

    free(mapped);
    return result;
}

- (NSOrderedSet *)cco_concurrentFilter:(CCOPredicateBlock)predicateBlock {
    NSParameterAssert(predicateBlock != nil);

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    return [self cco_concurrentWithQueue:queue filter:predicateBlock];
}

- (NSOrderedSet *)cco_concurrentWithQueue:(dispatch_queue_t)queue filter:(CCOPredicateBlock)predicateBlock {
    NSParameterAssert(predicateBlock != nil);

    NSOrderedSet *snapshot = [self copy];

    __unsafe_unretained id *objects = (__unsafe_unretained id*)calloc(snapshot.count, sizeof(id));
    [snapshot getObjects:objects range:NSMakeRange(0, snapshot.count)];

    __block NSUInteger filteredCount = 0;
    dispatch_apply(snapshot.count, queue, ^(size_t i) {
        if (predicateBlock(objects[i])) {
            ++filteredCount;
        } else {
            objects[i] = nil;
        }
    });

    NSMutableOrderedSet *temp = [NSMutableOrderedSet orderedSetWithCapacity:filteredCount];
    for (NSUInteger i = 0; i < snapshot.count; ++i) {
        if (objects[i] != nil) {
            [temp addObject:objects[i]];
        }
    }

    free(objects);

    NSOrderedSet *result = [NSOrderedSet orderedSetWithOrderedSet:temp];
    return result;
}

@end