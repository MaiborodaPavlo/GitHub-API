//
//  PMWebViewController.h
//  GitHub API
//
//  Created by Pavel on 17.02.2018.
//  Copyright © 2018 Pavel Maiboroda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WKWebView;

@interface PMWebViewController : UIViewController

@property (weak, nonatomic) IBOutlet WKWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

- (void) loadRequest: (NSURLRequest *) request;


@end
