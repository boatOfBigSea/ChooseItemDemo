//
//  KMItemCell.m
//  ChooseItemDemo
//
//  Created by user1 on 16/4/20.
//  Copyright (c) 2016年 Futaihua. All rights reserved.
//

#import "KMItemCell.h"
#import "KMItem.h"
#import "KMItemTool.h"

@interface KMItemCell()
@property(nonatomic,weak)UIButton *ImgBtn;
@end
@implementation KMItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIButton *ImgBtn=[[UIButton alloc]init];
        [ImgBtn addTarget:self action:@selector(ImgBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [ImgBtn setImage:[UIImage imageNamed:@"unselect.png"] forState:UIControlStateNormal];
        [ImgBtn setImage:[UIImage imageNamed:@"didselected.png"] forState:UIControlStateSelected];

        [self.contentView addSubview:ImgBtn];
        self.ImgBtn=ImgBtn;
        self.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    return self;
}

-(void)setItem:(KMItem *)item{

    _item=item;
    self.textLabel.text=item.title;
    self.detailTextLabel.text=item.applyName;
    self.ImgBtn.selected=item.isSelected;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.ImgBtn.frame=CGRectMake(30, 15, self.frame.size.height-25, self.frame.size.height-25);
    CGRect textF=self.textLabel.frame;
    textF=CGRectMake(textF.origin.x+50, textF.origin.y, textF.size.width, textF.size.height);
    self.textLabel.frame=textF;
    
    CGRect detailF=self.detailTextLabel.frame;
     detailF=CGRectMake(detailF.origin.x+50, detailF.origin.y, detailF.size.width, detailF.size.height);

    self.detailTextLabel.frame=detailF;
}
-(void)ImgBtnClick:(UIButton *)btn{
    
    if (btn.selected==YES) {
        self.item.selected=NO;
        [[KMItemTool sharedKMItemTool] deleteOneRecord:self.item];
        btn.selected=NO;
    }else{
        self.item.selected=YES;
        [[KMItemTool sharedKMItemTool]addOneRecord:self.item];
        btn.selected=YES;
    }
}
@end
