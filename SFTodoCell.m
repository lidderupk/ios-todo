//
//  SFTodoCell.m
//  TodoListApp
//
//  Created by Upkar Lidder on 2014-01-24.
//  Copyright (c) 2014 8indaas. All rights reserved.
//

#import "SFTodoCell.h"

@implementation SFTodoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
