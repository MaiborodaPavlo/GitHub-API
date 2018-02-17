//
//  PMRepository.m
//  GitHub API
//
//  Created by Pavel on 16.02.2018.
//  Copyright © 2018 Pavel Maiboroda. All rights reserved.
//

#import "PMRepository.h"

@implementation PMRepository

- (id) initWithServerResponse: (NSDictionary*) responseObject {
    self = [super init];
    if (self) {
        
        self.name = [responseObject objectForKey: @"full_name"];
        self.repositoryDescription = [responseObject objectForKey: @"description"];
        
        NSString* urlString = [responseObject objectForKey: @"html_url"];
        
        if (urlString) {
            self.url = [NSURL URLWithString: urlString];
        }
        
        self.starsCount = [[responseObject objectForKey: @"stargazers_count"] integerValue];
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.repositoryDescription forKey:@"repositoryDescription"];
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:@(self.starsCount) forKey:@"starsCount"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super init];
    if (self)
    {
        _name = [aDecoder decodeObjectForKey:@"name"];
        _repositoryDescription = [aDecoder decodeObjectForKey:@"repositoryDescription"];
        _url = [aDecoder decodeObjectForKey:@"url"];
        _starsCount = [[aDecoder decodeObjectForKey:@"starsCount"] integerValue];
    }
    return self;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    PMRepository *newRepository = [[self class] allocWithZone: zone];
    newRepository->_name = [_name copyWithZone:zone];
    newRepository->_repositoryDescription = [_repositoryDescription copyWithZone:zone];
    newRepository->_url = [_url copyWithZone:zone];
    newRepository->_starsCount = [[@(_starsCount) copyWithZone:zone] integerValue];
    
    return newRepository;
}

@end
