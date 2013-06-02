//
//  NSArray+ConcurrentCollectionOperations.h
//  ConcurrentCollectionOperations
//
//  Created by Dave Lee on 2013-06-02.
//  Copyright (c) 2013 Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id (^CCOMapBlock)(id object);
typedef BOOL (^CCOPredicateBlock)(id object);

@interface NSArray (ConcurrentCollectionOperations)

- (instancetype)cco_concurrentMap:(CCOMapBlock)mapBlock;
- (instancetype)cco_concurrentWithQueue:(dispatch_queue_t)queue map:(CCOMapBlock)mapBlock;

- (instancetype)cco_concurrentFilter:(CCOPredicateBlock)predicateBlock;
- (instancetype)cco_concurrentWithQueue:(dispatch_queue_t)queue filter:(CCOPredicateBlock)predicateBlock;

@end
