//
//  BusinessTableViewCell.m
//  Yelp
//
//  Created by Chris Guzman on 10/31/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import "BusinessTableViewCell.h"
#import "UIImageView+AFNetworking.h"

@implementation BusinessTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setBusiness:(YelpBusiness *) yelpBusiness {
    _yelpBusiness = yelpBusiness;
    [self.thumbInageView setImageWithURL: self.yelpBusiness.imageUrl];
    self.nameLabel.text = self.yelpBusiness.name;
    self.distanceLabel.text = self.yelpBusiness.distance;
    self.addressLabel.text = self.yelpBusiness.address;
    self.categoriesLabel.text = self.yelpBusiness.categories;
    [self.ratingImageView setImageWithURL: self.yelpBusiness.ratingImageUrl];
    self.reviewCountLabel.text = [NSString stringWithFormat:@"%@ Reviews", self.yelpBusiness.reviewCount];
    
}

@end
