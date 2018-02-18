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
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle: @"Done" style: UIBarButtonItemStyleDone target: self action: @selector(doneAction:)];
    
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadRequest: (NSURLRequest *) request {
    
    self.webView = [[WKWebView alloc] init];
    self.webView.frame = self.view.frame;
    
    [self.webView loadRequest: request];
    
    [self.view insertSubview: self.webView belowSubview: self.indicator];
    
    self.navigationItem.title = [self.webView.URL lastPathComponent];
}

#pragma mark - Actions

- (void) doneAction: (UIBarButtonItem *) sender {
    
    [self dismissViewControllerAnimated: YES completion: nil];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    
    [self.indicator startAnimating];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    
    [self.indicator stopAnimating];
}


@end
