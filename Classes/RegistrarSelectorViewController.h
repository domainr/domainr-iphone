//
//  RegistrarSelectorViewController.h
//  Domainr
//
//  Created by Sahil Desai on 2/9/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Result;

@interface RegistrarSelectorViewController : UITableViewController {
    Result *result;
}

@property (nonatomic, retain) Result *result;

- (id)initWithResult:(Result *)newResult;

@end
