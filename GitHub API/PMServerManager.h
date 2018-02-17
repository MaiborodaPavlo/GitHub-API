//
//  PMServerManager.h
//  GitHub API
//
//  Created by Pavel on 16.02.2018.
//  Copyright © 2018 Pavel Maiboroda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMServerManager : NSObject

+ (PMServerManager *) sharedManager;

- (void) getReposetoriesForQuery: (NSString *) query //GitHub API
                            page: (NSInteger) pageNumber
                       onSuccess:(void(^)(NSArray* repositories)) success;

- (void) getAllReposetoriesForQuery: (NSString *) query //GitHub API
                          onSuccess:(void(^)(NSArray* repositories)) success;

@end
