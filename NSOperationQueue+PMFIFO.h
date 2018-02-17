//
//  NSOperationQueue+PMFIFO.h
//  GitHub API
//
//  Created by Pavel on 17.02.2018.
//  Copyright © 2018 Pavel Maiboroda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSOperationQueue (PMFIFO)

- (void) addOperationAfterLast:(NSOperation *)op;

@end
