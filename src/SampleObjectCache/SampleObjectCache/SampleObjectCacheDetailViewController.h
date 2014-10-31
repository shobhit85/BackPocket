//
//  SampleObjectCacheDetailViewController.h
//  SampleObjectCache
//
//  Created by Shobhit Agarwal on 3/24/13.
//  Copyright (c) 2013 shobhita. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SampleObjectCacheDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
