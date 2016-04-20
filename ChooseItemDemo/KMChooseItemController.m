//
//  KMChooseItemController.m
//  ChooseItemDemo
//
//  Created by user1 on 16/4/20.
//  Copyright (c) 2016年 Futaihua. All rights reserved.
//

#import "KMChooseItemController.h"
#import "KMItem.h"
#import "KMItemCell.h"
#import "KMItemTool.h"
@interface KMChooseItemController ()
@property(nonatomic,strong)NSMutableArray *items;
@end

@implementation KMChooseItemController

-(NSMutableArray *)items{
    
    if (_items==nil) {
        _items=[NSMutableArray array];
        NSString *path=[[NSBundle mainBundle]pathForResource:@"item.plist" ofType:nil];        
        NSArray *itemArr=[NSMutableArray arrayWithContentsOfFile:path];
        
        NSMutableArray *muArr=[NSMutableArray array];
        for (NSDictionary *itemDic in itemArr) {
            KMItem *item=[KMItem KMItemWithDict:itemDic];
            
            [muArr addObject:item];
        }
        _items=muArr;
    }
    return _items;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"选择";
    UIBarButtonItem *leftItem=[[UIBarButtonItem alloc]initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(leftItemClick)];
    UIBarButtonItem *leftItem1=[[UIBarButtonItem alloc]initWithTitle:@"取消所有" style:UIBarButtonItemStylePlain target:self action:@selector(unselectedAllClick)];
    self.navigationItem.leftBarButtonItems=@[leftItem,leftItem1];

    UIBarButtonItem *rightItem=[[UIBarButtonItem alloc]initWithTitle:@"统计已选" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemClick)];
    self.navigationItem.rightBarButtonItem=rightItem;
    [self leftItemClick];
}

//全选
-(void)leftItemClick{
    for (int i=0; i<self.items.count; i++) {
        [[KMItemTool sharedKMItemTool]addOneRecord:self.items[i]];
    }
//    for (KMItem *item in self.items) {
//        [[KMItemTool sharedKMItemTool]addOneRecord:item];
//    }
//    [[KMItemTool sharedKMItemTool] addAllRecord:self.items];
    
    [self.tableView reloadData];

}

//取消全选
-(void)unselectedAllClick{
    
    [[KMItemTool sharedKMItemTool] unselectedAll];
    
    [self.tableView reloadData];
}

//统计已选
-(void)rightItemClick{
//    if ([[KMItemTool sharedKMItemTool] counAllRecord].count==0) {
//        NSLog(@"没有选中一条");
//        return;
//    }
    NSString *str=[NSString stringWithFormat:@"已选择%lu条单",(unsigned long)[[KMItemTool sharedKMItemTool] counAllRecord].count];
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"已选:" message:str delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    [alert show];
    for (KMItem *item in [[KMItemTool sharedKMItemTool] counAllRecord]) {
        NSLog(@"统计已选...标题：%@，申请人：%@",item.title,item.applyName);
        
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    KMItemCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell==nil){
        cell=[[KMItemCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    KMItem *item=self.items[indexPath.row];
    item.selected=[[KMItemTool sharedKMItemTool] hasThisitem:item.title];
    
    cell.item=item;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"点击了第%ld个cell",(long)indexPath.row);
}

@end
