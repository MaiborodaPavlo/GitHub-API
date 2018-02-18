//
//  ViewController.m
//  GitHub API
//
//  Created by Pavel on 16.02.2018.
//  Copyright © 2018 Pavel Maiboroda. All rights reserved.
//

#import "ViewController.h"
#import "PMServerManager.h"
#import "PMDataManger.h"
#import "PMRepository.h"
#import "PMRepositoryCell.h"
#import "PMWebViewController.h"

#import "NSOperationQueue+PMFIFO.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UIPopoverPresentationControllerDelegate>

@property (strong) NSMutableArray *repositories;

@property (assign, nonatomic) NSInteger currentPage;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;

@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) NSBlockOperation *firstOperation;
@property (strong, nonatomic) NSBlockOperation *secondOperation;

@property (assign, nonatomic) BOOL isFinish;
@property (assign, nonatomic) BOOL isOnline;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Repositiries";
    self.currentPage = 1;
    self.isFinish = NO;
    self.isOnline = NO;

    self.repositories = [NSMutableArray array];
    self.queue = [[NSOperationQueue alloc] init];
    
    
    self.indicator = [[UIActivityIndicatorView alloc] initWithFrame: CGRectMake(0, 0, 40, 40)];
    self.indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    self.indicator.color = [UIColor blueColor];
    self.indicator.center = self.view.center;
    [self.view addSubview: self.indicator];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    UIBarButtonItem *stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel target: self action: @selector(stopTasks:)];
    
    UIBarButtonItem *loadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh target: self action: @selector(actionLoad)];
    
    self.navigationItem.leftBarButtonItem = loadButton;
    self.navigationItem.rightBarButtonItem = stopButton;
    stopButton.enabled = NO;
    
    UIRefreshControl* refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget: self action: @selector(refreshTable) forControlEvents: UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    
    self.repositories = [[PMDataManger sharedManager] getRepositories];
    
    if ([self.repositories count] == 0) {
        
        stopButton.enabled = YES;
        [self loadNewPage];
    }
}



#pragma mark - Actions

- (void) refreshTable {
    
    [self.tableView reloadData];
    
    [self.refreshControl endRefreshing];
}

- (void) actionLoad {
    
    self.tableView.tableFooterView.hidden = YES;
    
    self.repositories = nil;
    self.repositories = [NSMutableArray array];
    self.currentPage = 1;
    self.isFinish = NO;
    self.isOnline = YES;
    
    [self.tableView reloadData];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    [self loadNewPage];
}

- (void) stopTasks: (UIBarButtonItem *) sender {
    
    self.isFinish = YES;
    self.tableView.tableFooterView.hidden = YES;
    
    [[PMDataManger sharedManager] saveRepositories: self.repositories];
    sender.enabled = NO;
    
    [self.queue cancelAllOperations];
}

- (void) loadNewPage {

    __weak ViewController* weakSelf = self;
    
    if (!self.isFinish) {
        
        if ([self.queue operationCount] < 2) {
            
            NSInteger i = 0;
            
            for (i = self.currentPage; i < self.currentPage + 2; i++) {
                
               NSOperation *someOperation = [NSBlockOperation blockOperationWithBlock:^{
                    NSLog(@"%ld", i);
                    
                    [[PMServerManager sharedManager] getReposetoriesForQuery: @"GitHub%20API"
                                                                        page: i
                                                                   onSuccess:^(NSArray *repositories) {
                       [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                           if ([repositories count] == 0) {
                               self.isFinish = YES;
                           } else {
                               [self.repositories addObjectsFromArray: repositories];
                               
                               NSLog(@"First %ld", [self.repositories count]);
                               
                               NSMutableArray* newPaths = [NSMutableArray array];
                               for (int i = (int)[self.repositories count] - (int)[repositories count]; i < [self.repositories count]; i++) {
                                   [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                               }
                               
                               [self.tableView beginUpdates];
                               [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationTop];
                               [self.tableView endUpdates];
                           }
                       }];
                   }];
                }];
                
               [self.queue addOperationAfterLast: someOperation];
                
            }
            
            self.currentPage = i;
        }
        
        [[PMDataManger sharedManager] saveRepositories: self.repositories];

        // Ограничение API: 10 запросов в минуту
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf loadNewPage];
        });
    } else {
        self.tableView.tableFooterView.hidden = YES;
        return;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([self.repositories count] == 0) {
        [self.indicator startAnimating];
    }
    
    return [self.repositories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.indicator stopAnimating];
    self.indicator.hidesWhenStopped = YES;

    static NSString *identifier = @"RepositoryCell";
    
    PMRepositoryCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
    
    PMRepository *repository = [self.repositories objectAtIndex: indexPath.row];
    
    if ([repository.name length] > 30) {
        repository.name = [repository.name substringToIndex: 30];
    }
    
    if ([repository.repositoryDescription length] > 30) {
        repository.repositoryDescription = [repository.repositoryDescription substringToIndex: 30];
    }
    
    cell.nameLabel.text = repository.name;
    cell.descriptionLabel.text = repository.repositoryDescription;
    cell.starsLabel.text = [NSString stringWithFormat: @"%lu", repository.starsCount];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    PMWebViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier: @"PMWebViewController"];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController: vc];
    
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    nav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal; 
    
    if(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
        nav.view.superview.frame = CGRectInset(nav.view.superview.frame, 10, 50);
    }else{
        nav.view.frame = CGRectInset(nav.view.frame, 10, 50);
        nav.view.superview.backgroundColor = [UIColor clearColor];
    }
    
    NSURL *url = [[self.repositories objectAtIndex: indexPath.row] url];
    NSURLRequest *request = [NSURLRequest requestWithURL: url];
    
    [vc loadRequest: request];

    [self presentViewController: nav animated: YES completion: nil];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (![self.indicator isAnimating] && self.isOnline) {
        
        NSInteger lastSectionIndex = tableView.numberOfSections - 1;
        NSInteger lastRowIndex = [tableView numberOfRowsInSection: lastSectionIndex] - 1;
        
        if (indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex) {
            
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
            [spinner startAnimating];
            spinner.frame = CGRectMake(0.f, 0.f, tableView.bounds.size.width, 44.f);
            
            tableView.tableFooterView = spinner;
            tableView.tableFooterView.hidden = NO;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60.f;
}

#pragma mark - UIPopoverPresentationControllerDelegate

- (UIModalPresentationStyle) adaptivePresentationStyleForPresentationController: (UIPresentationController *) controller {
    
    return UIModalPresentationNone;
}

@end
