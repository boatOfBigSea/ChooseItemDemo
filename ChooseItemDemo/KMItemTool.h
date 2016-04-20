//
//  KMItemTool.h
//  ChooseItemDemo
//
//  Created by user1 on 16/4/20.
//  Copyright (c) 2016年 Futaihua. All rights reserved.
//  

#import <Foundation/Foundation.h>
#import "Singleton.h"
@class KMItem;
@interface KMItemTool : NSObject
singleton_h(KMItemTool)

@property(nonatomic,strong)NSMutableArray *items;


/** 添加一条记录*/
-(void)addOneRecord:(KMItem *)item;

/** 删除一条记录*/
-(void)deleteOneRecord:(KMItem *)item;


/** 是否有这条记录*/
-(BOOL)hasThisitem:(NSString *)title;


/** 取消所有记录*/
-(void)unselectedAll;

/** 返回所有已选的记录*/
-(NSArray *)counAllRecord;

@end
