//
//  SFTodoModel.m
//  TodoListApp
//
//  Created by Upkar Lidder on 2014-01-26.
//  Copyright (c) 2014 8indaas. All rights reserved.
//

#import "SFTodoModel.h"
#import <Parse/PFObject+Subclass.h>

@implementation SFTodoModel

@dynamic itemText;

+ (NSString *)parseClassName {
    return @"SFTodoModel";
}

@end
