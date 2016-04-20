//
//  KMItem.m
//  ChooseItemDemo
//
//  Created by user1 on 16/4/20.
//  Copyright (c) 2016年 Futaihua. All rights reserved.
//

#import "KMItem.h"

@implementation KMItem
+(KMItem *)KMItemWithDict:(NSDictionary *)dict{
    return [[self alloc]itemWithDict:dict];
}
-(KMItem *)itemWithDict:(NSDictionary *)dict{
    KMItem *item=[[KMItem alloc]init];
    item.title=dict[@"title"];
    item.applyName=dict[@"applyName"];
    item.applyNum=dict[@"applyNum"];
    return item;
}
@end
