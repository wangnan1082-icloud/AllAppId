//
//  ViewController.m
//  AllAppId
//
//  Created by 王楠 on 2017/3/16.
//  Copyright © 2017年 combanc. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "BundleModel.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate>
{
    BOOL _shouldShowSearchResults;
}
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray * filteredArray;

@end

@implementation ViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"手机应用信息";
    
    _dataArray = [NSMutableArray arrayWithCapacity:10];
    _filteredArray = [NSMutableArray arrayWithCapacity:10];
    
    [self.view addSubview:self.myTableView];
    self.myTableView.frame = self.view.bounds;
    
    [self configureSearchController];

    [self getAppData];
}

#pragma mark - Setter

- (UITableView *)myTableView {
    if (!_myTableView) {
        _myTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        [_myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CellID"];
        _myTableView.delegate = self;
        _myTableView.dataSource = self;
        
    }
    return _myTableView;
}

#pragma mark - TableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID" forIndexPath:indexPath];
    cell.textLabel.numberOfLines = 0;
    if (self.dataArray.count > 0) {
        
        if (_shouldShowSearchResults) {
            BundleModel *model = self.filteredArray[indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@",model.localizedName,model.bundlId];
        }else{
            BundleModel *model = self.dataArray[indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@",model.localizedName,model.bundlId];
        }
        
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_shouldShowSearchResults) {
        return self.filteredArray.count;
    }
    return self.dataArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Search

- (void)configureSearchController {
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.searchResultsUpdater = self;
    _searchController.searchBar.placeholder = @"";
    _searchController.dimsBackgroundDuringPresentation = NO;
    _searchController.searchBar.delegate = self;
    [_searchController.searchBar sizeToFit];
    self.myTableView.tableHeaderView = _searchController.searchBar;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    _shouldShowSearchResults = YES;
    [self.myTableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    _shouldShowSearchResults = NO;
    [self.myTableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (!_shouldShowSearchResults) {
        _shouldShowSearchResults = YES;
        [self.myTableView reloadData];
    }
    [self.searchController.searchBar resignFirstResponder];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString * searchString = searchController.searchBar.text;
    
    NSMutableArray *searchResults = [self.dataArray mutableCopy];
    NSMutableArray *searchItemsPredicate = [NSMutableArray array];
    
    NSExpression *lhs = [NSExpression expressionForKeyPath:@"localizedName"];
    NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
    NSPredicate *finalPredicate = [NSComparisonPredicate
                                   predicateWithLeftExpression:lhs
                                   rightExpression:rhs
                                   modifier:NSDirectPredicateModifier
                                   type:NSContainsPredicateOperatorType
                                   options:NSCaseInsensitivePredicateOption];
    [searchItemsPredicate addObject:finalPredicate];
    self.filteredArray = [[searchResults filteredArrayUsingPredicate:finalPredicate] mutableCopy];
        
    [self.myTableView reloadData];
}

#pragma mark - getAppData

-(void)getAppData{
    Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
    NSObject* workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
    
    NSArray *allBundleIds = [workspace performSelector:@selector(allApplications)];
    
    Class LSApplicationProxy_class = objc_getClass("LSApplicationProxy");
    
    for (LSApplicationProxy_class in allBundleIds) {
        NSString *bundlId = [LSApplicationProxy_class performSelector:(@selector(applicationIdentifier)) ];
        NSString *localizedName = [LSApplicationProxy_class performSelector:(@selector(localizedName)) ];
        NSString *localizedShortName = [LSApplicationProxy_class performSelector:(@selector(localizedShortName)) ];
        NSString *minimumSystemVersion = [LSApplicationProxy_class performSelector:(@selector(minimumSystemVersion)) ];
        
//        NSLog(@"bundlId: %@ localizedName: %@ localizedShortName: %@ ",bundlId, localizedName, localizedShortName);
        
        BundleModel *model = [[BundleModel alloc] init];
        model.bundlId = bundlId;
        model.localizedShortName = localizedShortName;
        model.localizedName = localizedName;
        [self.dataArray addObject:model];
    }
    
    [self.myTableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
