//
//  MainViewController.m
//  Yelp
//
//  Created by Timothy Lee on 3/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "MainViewController.h"
#import "YelpBusiness.h"
#import "BusinessTableViewCell.h"
#import "FilterViewController.h"

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FilterViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *businesses;
@property NSString *theSearchTerm;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Yelp";
    self.theSearchTerm = @"Restaurants";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    UISearchBar *search = [[UISearchBar alloc] init];
    search.returnKeyType = UIReturnKeySearch;
    search.delegate = self;
    self.navigationItem.titleView = search;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterTapped)];
    [self.tableView registerNib:[UINib nibWithNibName:@"BusinessTableViewCell" bundle:nil] forCellReuseIdentifier:@"BusinessTableViewCell"];
    [YelpBusiness searchWithTerm:self.theSearchTerm
                        sortMode:YelpSortModeBestMatched
                      categories:nil
                           deals:NO
                      completion:^(NSArray *yelpBusinesses, NSError *error) {
//                          NSLog(@"%@", yelpBusinesses);
                          for (YelpBusiness *business in yelpBusinesses) {
                              NSLog(@"%@", business);
                          }
                          @try {
                              self.businesses = yelpBusinesses;
                                  [self.tableView reloadData];
                          }
                          @catch (NSException *exception) {
                              NSLog(@"Gosh!!! %@", [exception callStackSymbols]);
                          }
                          @finally {
                          }
                      }];
    self.tableView.estimatedRowHeight = 100.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView reloadData];
}



// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *searchTerm = searchBar.text;
    self.theSearchTerm = searchTerm;
    [YelpBusiness searchWithTerm:searchTerm
                        sortMode:YelpSortModeBestMatched
                      categories:nil
                           deals:NO
                      completion:^(NSArray *yelpBusinesses, NSError *error) {
                          //                          NSLog(@"%@", yelpBusinesses);
                          for (YelpBusiness *business in yelpBusinesses) {
                              NSLog(@"%@", business);
                          }
                          @try {
                              self.businesses = yelpBusinesses;
                              [self.tableView reloadData];
                          }
                          @catch (NSException *exception) {
                              NSLog(@"Gosh!!! %@", [exception callStackSymbols]);
                          }
                          @finally {
                          }
                      }];
}
    
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.businesses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BusinessTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessTableViewCell"];
    cell.yelpBusiness = self.businesses[indexPath.row];
    [cell setBusiness: cell.yelpBusiness];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Filter delegate methods

-(void)filterViewController:(FilterViewController *)filterViewController didChangeFilters:(NSDictionary *)filters {
    //fire network event
    NSLog(@"fire event: %@", filters);
    [YelpBusiness searchWithTerm:self.theSearchTerm
                        sortMode:YelpSortModeBestMatched
                      categories:filters[@"category_filter"]
                           deals:NO
                      completion:^(NSArray *yelpBusinesses, NSError *error) {
                          //                          NSLog(@"%@", yelpBusinesses);
                          for (YelpBusiness *business in yelpBusinesses) {
                              NSLog(@"%@", business);
                          }
                          @try {
                              self.businesses = yelpBusinesses;
                              [self.tableView reloadData];
                          }
                          @catch (NSException *exception) {
                              NSLog(@"Gosh!!! %@", [exception callStackSymbols]);
                          }
                          @finally {
                          }
                      }];
}

#pragma mark - Private methods 
-(void)onFilterTapped {
    FilterViewController *vc = [[FilterViewController alloc] init];
    vc.delegate = self;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:nvc animated:YES completion:nil];
    
}


@end

