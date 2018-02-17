//
//  PMServerManager.m
//  GitHub API
//
//  Created by Pavel on 16.02.2018.
//  Copyright © 2018 Pavel Maiboroda. All rights reserved.
//

#import "PMServerManager.h"
#import "PMRepository.h"

@implementation PMServerManager

+ (PMServerManager *) sharedManager {
    
    static PMServerManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[PMServerManager alloc] init];
    });
    
    return manager;
}

- (void) getReposetoriesForQuery: (NSString *) query //GitHub API
                            page: (NSInteger) pageNumber
                       onSuccess:(void(^)(NSArray* repositories)) success {
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"https://api.github.com/search/repositories?q=%@&sort=stars&order=desc&per_page=15&page=%ld", query, pageNumber];
    [request setURL: [NSURL URLWithString: urlString]];
    [request setHTTPMethod: @"GET"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest: request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      if (data == nil) {
                                          [self printCannotLoad];
                                      } else {
                                          if (success) {
                                              success([self parseJSON: data]);
                                              
                                          }
                                          
                                      }
                                  }];
    [task resume];
}

- (void) getAllReposetoriesForQuery: (NSString *) query //GitHub API
                       onSuccess:(void(^)(NSArray* repositories)) success {
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"https://api.github.com/search/repositories?q=%@&sort=stars&order=desc&page=800", query];
    [request setURL: [NSURL URLWithString: urlString]];
    [request setHTTPMethod: @"GET"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest: request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      if (data == nil) {
                                          [self printCannotLoad];
                                      } else {
                                          NSLog(@"%ld", [[self parseJSON: data] count]);
                                      }
                                  }];
    [task resume];
}

- (NSArray *) parseJSON: (NSData *) jsonData {
    
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData: jsonData options: NSJSONReadingMutableContainers error: &error];
    
    if (error) {
        [self printCannotLoad];
        return nil;
    }
    
    if ([object isKindOfClass: [NSDictionary class]]) {
        
        //NSLog(@"%@", object);
        
        NSDictionary *repositories = [object valueForKey: @"items"];
        NSMutableArray *repositoriesArray = [NSMutableArray array];
        
        for (NSDictionary *repository in repositories) {
            PMRepository *repositoryObject = [[PMRepository alloc] initWithServerResponse: repository];
            [repositoriesArray addObject: repositoryObject];
        }
        
        return repositoriesArray;
    } else {
        return nil;
    }
}


- (void) printCannotLoad {
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"cannot load");
    });
}

@end
