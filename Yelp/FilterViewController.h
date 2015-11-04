//
//  FilterViewController.h
//  Yelp
//
//  Created by Chris Guzman on 11/2/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FilterViewController;

@protocol FilterViewControllerDelegate <NSObject>

-(void) filterViewController:(FilterViewController *) filterViewController didChangeFilters:(NSDictionary *)filters;

@end

@interface FilterViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, weak) id<FilterViewControllerDelegate> delegate;

@end
