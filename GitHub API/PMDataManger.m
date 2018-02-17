//
//  PMDataManger.m
//  GitHub API
//
//  Created by Pavel on 17.02.2018.
//  Copyright © 2018 Pavel Maiboroda. All rights reserved.
//

#import "PMDataManger.h"

@implementation PMDataManger

+ (PMDataManger *) sharedManager {
    
    static PMDataManger *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[PMDataManger alloc] init];
    });
    
    return manager;
}

- (void) saveRepositories: (NSArray *) repositories {
    
    NSString * filename = [NSHomeDirectory() stringByAppendingString:@"/Documents/repositories.bin"];
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject: repositories];
    [data writeToFile: filename atomically: YES];
}

- (NSMutableArray *) getRepositories {
    
    NSData *data = [NSData dataWithContentsOfFile:[NSHomeDirectory() stringByAppendingString:@"/Documents/repositories.bin"]];
    
    return [NSKeyedUnarchiver unarchiveObjectWithData: data];
}

@end
