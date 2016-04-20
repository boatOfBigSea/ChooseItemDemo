//
//  KMItemTool.m
//  ChooseItemDemo
//
//  Created by user1 on 16/4/20.
//  Copyright (c) 2016年 Futaihua. All rights reserved.
//

#import "KMItemTool.h"
#import "KMItem.h"
@implementation KMItemTool

singleton_m(KMItemTool)
-(NSMutableArray *)items{
    if (_items==nil) {
        _items=[NSMutableArray array];
    }
    return _items;
}

-(BOOL)hasThisitem:(NSString *)title{
    for (int i=0; i<self.items.count; i++) {
        if ([[self.items[i] title] isEqualToString:title]) {
            return YES;
        }
    }
    return NO;
}

-(void)addOneRecord:(KMItem *)item{
//    if (self.items.count==0) {
//        [self.items addObject:item];
//        
//        return;
//    }
    for (int i=0; i<self.items.count; i++) {
        if ([[self.items[i] title] isEqualToString:item.title]) {
            return;
        }
    }
    [self.items addObject:item];
}

-(void)deleteOneRecord:(KMItem *)item{

    int index=0;
    if (self.items.count<1) {
        return;
    }
    for (int i=0; i<self.items.count; i++) {
        if ([[self.items[i] applyNum] isEqualToString:item.applyNum]) {
            index=i;
        }
    }
    [self.items removeObject:self.items[index]];
}
//-(void)addAllRecord:(NSArray *)arr{
//    _items=(NSMutableArray *)arr;
//    for (KMItem *item in _items) {
//        item.selected=YES;
//    }
//}
-(void)unselectedAll{
    for (KMItem *item in self.items) {
        item.selected=NO;
    }
    [self.items removeAllObjects];
}

-(NSArray *)counAllRecord {

    return _items;
}
@end
