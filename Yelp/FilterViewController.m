//
//  FilterViewController.m
//  Yelp
//
//  Created by Chris Guzman on 11/2/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import "FilterViewController.h"
#import "SwitchCell.h"

@interface FilterViewController () <UITableViewDelegate, UITableViewDataSource, SwitchCellDelegate>

@property (nonatomic, readonly) NSDictionary *filters;
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSMutableSet *selectedCategories;
@property (nonatomic, strong) NSNumber *selectedDistance;
@property (nonatomic, assign) NSNumber *wantsDeals;
@property (nonatomic, assign) NSNumber *sortMode;
-(void) initFilters;

@end

@implementation FilterViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.selectedCategories = [NSMutableSet set];
        [self initFilters];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"SwitchCell" bundle:nil] forCellReuseIdentifier:@"SwitchCell"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(onApplyButton)];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.data.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *filterDictionary = [self.data objectAtIndex:section];
    NSArray *elementsArray = filterDictionary[@"elements"];
    return elementsArray.count;
}


- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.data[section][@"title"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SwitchCell *cell = [tableView   dequeueReusableCellWithIdentifier:@"SwitchCell"];
    

    NSDictionary *filterDictionary = [self.data objectAtIndex:indexPath.section];
    NSArray *elementsArray = filterDictionary[@"elements"];
    NSDictionary *element = [elementsArray objectAtIndex:indexPath.row];
    cell.titleLabel.text = element[@"name"];
    cell.delegate = self;
    if ([filterDictionary[@"title"] isEqualToString:@"Categories"]) {
        cell.on = [self.selectedCategories containsObject:element];
    }
    if ([filterDictionary[@"title"] isEqualToString:@"Distance"]) {
        cell.on = self.selectedDistance;
    }
    else if ([filterDictionary[@"title"] isEqualToString:@"Offering Deals"]) {
        cell.on = [self.wantsDeals boolValue];
    }
    else if ([filterDictionary[@"title"] isEqualToString:@"Sort By"]) {
        cell.on = [self.sortMode boolValue];
    }

    return cell;
}

#pragma mark - Switch cell delegate methods

-(void)switchCell:(SwitchCell *)cell didUpdateValue:(BOOL)value {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSDictionary *filterDictionary = [self.data objectAtIndex:indexPath.section];
    NSArray *elementsArray = filterDictionary[@"elements"];
    NSDictionary *element = [elementsArray objectAtIndex:indexPath.row];
    NSString *elementName = element[@"name"];
    if ([elementName isEqualToString:@"Deals?"]) {
        self.wantsDeals = [NSNumber numberWithBool:value];;
    }
    else if ([filterDictionary[@"title"] isEqualToString:@"Categories"]) {
        if (value) {
            [self.selectedCategories addObject:element];
        } else  {
            [self.selectedCategories removeObject:element];
        }
    }
    else if ([filterDictionary[@"title"] isEqualToString:@"Distance"]) {
        if (value) {
            self.selectedDistance = element[@"code"];
        } else  {
            self.selectedDistance = nil;
        }
    }
    else if ([filterDictionary[@"title"] isEqualToString:@"Sort By"]) {
        if (value) {
            self.sortMode = element[@"code"];
        } else  {
            self.sortMode = nil;
        }
    }
    
//    NSIndexPath *indexPath  =[self.tableView indexPathForCell:cell];
//    NSLog(@"%ld is on", (long)indexPath.row);
//    if (value) {
//        [self.selectedCategories addObject:self.categories[indexPath.row]];
//    } else  {
//        [self.selectedCategories removeObject:self.categories[indexPath.row]];
//    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark -Private methods

-(NSDictionary *)filters {
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    
    if (self.selectedCategories.count > 0) {
        NSMutableArray *names = [NSMutableArray array];
        for (NSDictionary *category in self.selectedCategories) {
            [names addObject: category[@"code"]];
        }
        
                NSString *categoryFilter = [names componentsJoinedByString:@","];
        [filters setObject:categoryFilter forKey:@"category_filter"];
    }
    if (self.wantsDeals) {
        [filters setObject:self.wantsDeals forKey:@"deals_filter"];
    }
    if (self.selectedDistance) {
        NSNumber *distance = self.selectedDistance;
        [filters setObject:distance forKey:@"distance"];
    }
    if (self.sortMode) {
        NSNumber *mode = self.sortMode;
        [filters setObject:mode forKey:@"sort_mode"];
    }
    
    return filters;
}

-(void)onCancelButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)onApplyButton {
    [self.delegate filterViewController:self didChangeFilters:self.filters];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) initFilters{
    self.data = @[
                  @{@"title": @"Sort By",
                    @"elements":
                        @[@{@"name": @"Highest rated", @"code": @3}]},
                  @{@"title": @"Distance",
                    @"elements":
                        @[@{@"name": @"Within 10 miles", @"code": @10}]},
                  @{@"title": @"Offering Deals",
                    @"elements":
                        @[@{@"name": @"Deals?", @"code": @YES}]},
                  @{@"title": @"Categories",
                    @"elements":
                        @[@{@"name": @"Afghan", @"code": @"afghani"},
                          @{@"name": @"African", @"code": @"african"},
                          @{@"name": @"American, New", @"code": @"newamerican"},
                          @{@"name": @"American, Traditional", @"code": @"tradamerican"},
                          @{@"name": @"Arabian", @"code": @"arabian"},
                          @{@"name": @"Argentine", @"code": @"argentine"},
                          @{@"name": @"Armenian", @"code": @"armenian"},
                          @{@"name": @"Asian Fusion", @"code": @"asianfusion"},
                          @{@"name": @"Asturian", @"code": @"asturian"},
                          @{@"name": @"Australian", @"code": @"australian"},
                          @{@"name": @"Austrian", @"code": @"austrian"},
                          @{@"name": @"Baguettes", @"code": @"baguettes"},
                          @{@"name": @"Bangladeshi", @"code": @"bangladeshi"},
                          @{@"name": @"Barbeque", @"code": @"bbq"},
                          @{@"name": @"Basque", @"code": @"basque"},
                          @{@"name": @"Bavarian", @"code": @"bavarian"},
                          @{@"name": @"Beer Garden", @"code": @"beergarden"},
                          @{@"name": @"Beer Hall", @"code": @"beerhall"},
                          @{@"name": @"Beisl", @"code": @"beisl"},
                          @{@"name": @"Belgian", @"code": @"belgian"},
                          @{@"name": @"Bistros", @"code": @"bistros"},
                          @{@"name": @"Black Sea", @"code": @"blacksea"},
                          @{@"name": @"Brasseries", @"code": @"brasseries"},
                          @{@"name": @"Brazilian", @"code": @"brazilian"},
                          @{@"name": @"Breakfast & Brunch", @"code": @"breakfast_brunch"},
                          @{@"name": @"British", @"code": @"british"},
                          @{@"name": @"Buffets", @"code": @"buffets"},
                          @{@"name": @"Bulgarian", @"code": @"bulgarian"},
                          @{@"name": @"Burgers", @"code": @"burgers"},
                          @{@"name": @"Burmese", @"code": @"burmese"},
                          @{@"name": @"Cafes", @"code": @"cafes"},
                          @{@"name": @"Cafeteria", @"code": @"cafeteria"},
                          @{@"name": @"Cajun/Creole", @"code": @"cajun"},
                          @{@"name": @"Cambodian", @"code": @"cambodian"},
                          @{@"name": @"Canadian", @"code": @"New)"},
                          @{@"name": @"Canteen", @"code": @"canteen"},
                          @{@"name": @"Caribbean", @"code": @"caribbean"},
                          @{@"name": @"Catalan", @"code": @"catalan"},
                          @{@"name": @"Chech", @"code": @"chech"},
                          @{@"name": @"Cheesesteaks", @"code": @"cheesesteaks"},
                          @{@"name": @"Chicken Shop", @"code": @"chickenshop"},
                          @{@"name": @"Chicken Wings", @"code": @"chicken_wings"},
                          @{@"name": @"Chilean", @"code": @"chilean"},
                          @{@"name": @"Chinese", @"code": @"chinese"},
                          @{@"name": @"Comfort Food", @"code": @"comfortfood"},
                          @{@"name": @"Corsican", @"code": @"corsican"},
                          @{@"name": @"Creperies", @"code": @"creperies"},
                          @{@"name": @"Cuban", @"code": @"cuban"},
                          @{@"name": @"Curry Sausage", @"code": @"currysausage"},
                          @{@"name": @"Cypriot", @"code": @"cypriot"},
                          @{@"name": @"Czech", @"code": @"czech"},
                          @{@"name": @"Czech/Slovakian", @"code": @"czechslovakian"},
                          @{@"name": @"Danish", @"code": @"danish"},
                          @{@"name": @"Delis", @"code": @"delis"},
                          @{@"name": @"Diners", @"code": @"diners"},
                          @{@"name": @"Dumplings", @"code": @"dumplings"},
                          @{@"name": @"Eastern European", @"code": @"eastern_european"},
                          @{@"name": @"Ethiopian", @"code": @"ethiopian"},
                          @{@"name": @"Fast Food", @"code": @"hotdogs"},
                          @{@"name": @"Filipino", @"code": @"filipino"},
                          @{@"name": @"Fish & Chips", @"code": @"fishnchips"},
                          @{@"name": @"Fondue", @"code": @"fondue"},
                          @{@"name": @"Food Court", @"code": @"food_court"},
                          @{@"name": @"Food Stands", @"code": @"foodstands"},
                          @{@"name": @"French", @"code": @"french"},
                          @{@"name": @"French Southwest", @"code": @"sud_ouest"},
                          @{@"name": @"Galician", @"code": @"galician"},
                          @{@"name": @"Gastropubs", @"code": @"gastropubs"},
                          @{@"name": @"Georgian", @"code": @"georgian"},
                          @{@"name": @"German", @"code": @"german"},
                          @{@"name": @"Giblets", @"code": @"giblets"},
                          @{@"name": @"Gluten-Free", @"code": @"gluten_free"},
                          @{@"name": @"Greek", @"code": @"greek"},
                          @{@"name": @"Halal", @"code": @"halal"},
                          @{@"name": @"Hawaiian", @"code": @"hawaiian"},
                          @{@"name": @"Heuriger", @"code": @"heuriger"},
                          @{@"name": @"Himalayan/Nepalese", @"code": @"himalayan"},
                          @{@"name": @"Hong Kong Style Cafe", @"code": @"hkcafe"},
                          @{@"name": @"Hot Dogs", @"code": @"hotdog"},
                          @{@"name": @"Hot Pot", @"code": @"hotpot"},
                          @{@"name": @"Hungarian", @"code": @"hungarian"},
                          @{@"name": @"Iberian", @"code": @"iberian"},
                          @{@"name": @"Indian", @"code": @"indpak"},
                          @{@"name": @"Indonesian", @"code": @"indonesian"},
                          @{@"name": @"International", @"code": @"international"},
                          @{@"name": @"Irish", @"code": @"irish"},
                          @{@"name": @"Island Pub", @"code": @"island_pub"},
                          @{@"name": @"Israeli", @"code": @"israeli"},
                          @{@"name": @"Italian", @"code": @"italian"},
                          @{@"name": @"Japanese", @"code": @"japanese"},
                          @{@"name": @"Jewish", @"code": @"jewish"},
                          @{@"name": @"Kebab", @"code": @"kebab"},
                          @{@"name": @"Korean", @"code": @"korean"},
                          @{@"name": @"Kosher", @"code": @"kosher"},
                          @{@"name": @"Kurdish", @"code": @"kurdish"},
                          @{@"name": @"Laos", @"code": @"laos"},
                          @{@"name": @"Laotian", @"code": @"laotian"},
                          @{@"name": @"Latin American", @"code": @"latin"},
                          @{@"name": @"Live/Raw Food", @"code": @"raw_food"},
                          @{@"name": @"Lyonnais", @"code": @"lyonnais"},
                          @{@"name": @"Malaysian", @"code": @"malaysian"},
                          @{@"name": @"Meatballs", @"code": @"meatballs"},
                          @{@"name": @"Mediterranean", @"code": @"mediterranean"},
                          @{@"name": @"Mexican", @"code": @"mexican"},
                          @{@"name": @"Middle Eastern", @"code": @"mideastern"},
                          @{@"name": @"Milk Bars", @"code": @"milkbars"},
                          @{@"name": @"Modern Australian", @"code": @"modern_australian"},
                          @{@"name": @"Modern European", @"code": @"modern_european"},
                          @{@"name": @"Mongolian", @"code": @"mongolian"},
                          @{@"name": @"Moroccan", @"code": @"moroccan"},
                          @{@"name": @"New Zealand", @"code": @"newzealand"},
                          @{@"name": @"Night Food", @"code": @"nightfood"},
                          @{@"name": @"Norcinerie", @"code": @"norcinerie"},
                          @{@"name": @"Open Sandwiches", @"code": @"opensandwiches"},
                          @{@"name": @"Oriental", @"code": @"oriental"},
                          @{@"name": @"Pakistani", @"code": @"pakistani"},
                          @{@"name": @"Parent Cafes", @"code": @"eltern_cafes"},
                          @{@"name": @"Parma", @"code": @"parma"},
                          @{@"name": @"Persian/Iranian", @"code": @"persian"},
                          @{@"name": @"Peruvian", @"code": @"peruvian"},
                          @{@"name": @"Pita", @"code": @"pita"},
                          @{@"name": @"Pizza", @"code": @"pizza"},
                          @{@"name": @"Polish", @"code": @"polish"},
                          @{@"name": @"Portuguese", @"code": @"portuguese"},
                          @{@"name": @"Potatoes", @"code": @"potatoes"},
                          @{@"name": @"Poutineries", @"code": @"poutineries"},
                          @{@"name": @"Pub Food", @"code": @"pubfood"},
                          @{@"name": @"Rice", @"code": @"riceshop"},
                          @{@"name": @"Romanian", @"code": @"romanian"},
                          @{@"name": @"Rotisserie Chicken", @"code": @"rotisserie_chicken"},
                          @{@"name": @"Rumanian", @"code": @"rumanian"},
                          @{@"name": @"Russian", @"code": @"russian"},
                          @{@"name": @"Salad", @"code": @"salad"},
                          @{@"name": @"Sandwiches", @"code": @"sandwiches"},
                          @{@"name": @"Scandinavian", @"code": @"scandinavian"},
                          @{@"name": @"Scottish", @"code": @"scottish"},
                          @{@"name": @"Seafood", @"code": @"seafood"},
                          @{@"name": @"Serbo Croatian", @"code": @"serbocroatian"},
                          @{@"name": @"Signature Cuisine", @"code": @"signature_cuisine"},
                          @{@"name": @"Singaporean", @"code": @"singaporean"},
                          @{@"name": @"Slovakian", @"code": @"slovakian"},
                          @{@"name": @"Soul Food", @"code": @"soulfood"},
                          @{@"name": @"Soup", @"code": @"soup"},
                          @{@"name": @"Southern", @"code": @"southern"},
                          @{@"name": @"Spanish", @"code": @"spanish"},
                          @{@"name": @"Steakhouses", @"code": @"steak"},
                          @{@"name": @"Sushi Bars", @"code": @"sushi"},
                          @{@"name": @"Swabian", @"code": @"swabian"},
                          @{@"name": @"Swedish", @"code": @"swedish"},
                          @{@"name": @"Swiss Food", @"code": @"swissfood"},
                          @{@"name": @"Tabernas", @"code": @"tabernas"},
                          @{@"name": @"Taiwanese", @"code": @"taiwanese"},
                          @{@"name": @"Tapas Bars", @"code": @"tapas"},
                          @{@"name": @"Tapas/Small Plates", @"code": @"tapasmallplates"},
                          @{@"name": @"Tex-Mex", @"code": @"tex-mex"},
                          @{@"name": @"Thai", @"code": @"thai"},
                          @{@"name": @"Traditional Norwegian", @"code": @"norwegian"},
                          @{@"name": @"Traditional Swedish", @"code": @"traditional_swedish"},
                          @{@"name": @"Trattorie", @"code": @"trattorie"},
                          @{@"name": @"Turkish", @"code": @"turkish"},
                          @{@"name": @"Ukrainian", @"code": @"ukrainian"},
                          @{@"name": @"Uzbek", @"code": @"uzbek"},
                          @{@"name": @"Vegan", @"code": @"vegan"},
                          @{@"name": @"Vegetarian", @"code": @"vegetarian"},
                          @{@"name": @"Venison", @"code": @"venison"},
                          @{@"name": @"Vietnamese", @"code": @"vietnamese"},
                          @{@"name": @"Wok", @"code": @"wok"},
                          @{@"name": @"Wraps", @"code": @"wraps"},
                          @{@"name": @"Yugoslav", @"code": @"yugoslav"}]
                    }
                  ];
    self.categories = self.data[1];
}

@end
