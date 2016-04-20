//
//  KMItemCell.h
//  ChooseItemDemo
//
//  Created by user1 on 16/4/20.
//  Copyright (c) 2016年 Futaihua. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KMItem;
@interface KMItemCell : UITableViewCell
/* 传入Item*/
@property(nonatomic,strong)KMItem *item;
@end
