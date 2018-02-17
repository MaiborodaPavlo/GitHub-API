//
//  PMWebViewController.m
//  GitHub API
//
//  Created by Pavel on 17.02.2018.
//  Copyright © 2018 Pavel Maiboroda. All rights reserved.
//

#import "PMWebViewController.h"

#import <WebKit/WebKit.h>

@interface PMWebViewController () <WKNavigationDelegate>


@end

@implementation PMWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView.navigationDelegate = self;
    
    [self.webView addObserver: self forKeyPath:@"estimatedProgress" options: NSKeyValueObservingOptionNew context: nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadRequest: (NSURLRequest *) request {
    
    self.webView = [[WKWebView alloc] init];
    self.webView.frame = self.view.frame;
    
    [self.webView loadRequest: request];
    
    [self.view insertSubview: self.webView belowSubview: self.progressView];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    
    [self.progressView setHidden: NO];
    
    NSLog(@"%@", self.webView.URL);
    NSLog(@"didStartProvisionalNavigation");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    
    [self.progressView setHidden: YES];
    NSLog(@"didFinishNavigation");

    [self.webView removeObserver: self forKeyPath: @"estimatedProgress"];
}

#pragma mark - Observing

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context {
    
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        NSLog(@"%@", change[NSKeyValueChangeNewKey]);
        [self.progressView setProgress: [change[NSKeyValueChangeNewKey] integerValue] animated: YES];
    }
    
}


@end
