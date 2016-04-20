//
//  KMItem.h
//  ChooseItemDemo
//
//  Created by user1 on 16/4/20.
//  Copyright (c) 2016年 Futaihua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMItem : NSObject
/* 标题*/
@property(nonatomic,strong)NSString *title;
/* 申请人姓名*/
@property(nonatomic,strong)NSString *applyName;
/* 申请编号*/
@property(nonatomic,strong)NSString *applyNum;
/* 是否选择*/
@property(nonatomic,assign,getter = isSelected)BOOL selected;


+(KMItem *)KMItemWithDict:(NSDictionary *)dict;
-(KMItem *)itemWithDict:(NSDictionary *)dict;
@end
