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
@property (strong, nonatomic) NSMutableArray *businesses;
@property NSString *searchTerm;
@property (strong, nonatomic) NSNumber *dealsOn;
@property (strong, nonatomic) NSString *categoryFilter;
@property (strong, nonatomic) NSNumber *sortMode;
@property (strong, nonatomic) NSNumber *distance;
@property (strong, nonatomic) NSNumber *currentOffset;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Yelp";
    self.searchTerm = @"Restaurants";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    UISearchBar *search = [[UISearchBar alloc] init];
    search.returnKeyType = UIReturnKeySearch;
    search.delegate = self;
    self.navigationItem.titleView = search;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterTapped)];
    [self.tableView registerNib:[UINib nibWithNibName:@"BusinessTableViewCell" bundle:nil] forCellReuseIdentifier:@"BusinessTableViewCell"];
    self.businesses = [[NSMutableArray alloc] init];
    [self yelpSearch:self.searchTerm withCategory:@"" withDeals:[@NO boolValue] withSortMode:YelpSortModeBestMatched withDistance:nil atOffset:@0];
    self.tableView.estimatedRowHeight = 100.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void) yelpSearch:(NSString *) searchTerm withCategory:(NSString *) categoryFilter withDeals:(BOOL) isOn withSortMode:(YelpSortMode) sortMode withDistance:(NSNumber *) distance atOffset:(NSNumber *) offset {
    [YelpBusiness searchWithTerm:searchTerm
                        sortMode:sortMode
                      categories:@[categoryFilter ? categoryFilter :@""]
                           deals:isOn
                        distance:distance
                          offset:offset
                      completion:^(NSArray *yelpBiz, NSError *error) {
                          NSLog(@"Restaurant count: %lu", (unsigned long)yelpBiz.count);
                          [self.businesses addObjectsFromArray:yelpBiz];
                          [self.tableView reloadData];
                      }];
}



// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *text = [searchBar text];
    [self searchWithTerm:text];
}

- (void) searchWithTerm:(NSString*) text {
    if(text && [text length] != 0) {
        self.searchTerm = text;
    } else {
        self.searchTerm = @"Restaurants";
    }
    self.businesses = [[NSMutableArray alloc] init];
    [self yelpSearch:self.searchTerm withCategory:@"" withDeals:[@NO boolValue] withSortMode:YelpSortModeBestMatched withDistance:nil atOffset:@0];
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
    self.businesses = [[NSMutableArray alloc] init];
    self.dealsOn = [filters objectForKey:@"deals_filter"];
    self.sortMode = [filters objectForKey:@"sort_mode"];
    self.distance = [filters objectForKey:@"distance"];
    self.categoryFilter = [filters objectForKey:@"category_filter"];
    self.currentOffset = @0;
    YelpSortMode yelpSortMode;
    if(self.sortMode) {
        yelpSortMode = YelpSortModeHighestRated;
    } else {
        yelpSortMode = YelpSortModeBestMatched;
    }
    [self yelpSearch:self.searchTerm withCategory:self.categoryFilter withDeals:[self.dealsOn boolValue] withSortMode:yelpSortMode withDistance:self.distance atOffset:self.currentOffset];
}

#pragma mark - Private methods 
-(void)onFilterTapped {
    FilterViewController *vc = [[FilterViewController alloc] init];
    vc.delegate = self;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:nvc animated:YES completion:nil];
    
}


@end

