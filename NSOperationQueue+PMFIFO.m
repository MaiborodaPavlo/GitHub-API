//
//  NSOperationQueue+PMFIFO.m
//  GitHub API
//
//  Created by Pavel on 17.02.2018.
//  Copyright © 2018 Pavel Maiboroda. All rights reserved.
//

#import "NSOperationQueue+PMFIFO.h"

@implementation NSOperationQueue (PMFIFO)

- (void) addOperationAfterLast: (NSOperation *) op {
    
    if (self.maxConcurrentOperationCount != 1) {
        self.maxConcurrentOperationCount = 1;
    }
    
    NSOperation *lastOp = [self.operations lastObject];
    
    if (lastOp != nil) {
        [op addDependency: lastOp];
    }
    
    [self addOperation: op];
}

@end
