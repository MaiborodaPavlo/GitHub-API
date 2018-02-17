//
//  PMRepository.h
//  GitHub API
//
//  Created by Pavel on 16.02.2018.
//  Copyright © 2018 Pavel Maiboroda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMRepository : NSObject <NSCopying>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *repositoryDescription;
@property (strong, nonatomic) NSURL *url;
@property (assign, nonatomic) NSUInteger starsCount;

- (id) initWithServerResponse: (NSDictionary*) responseObject;

@end
