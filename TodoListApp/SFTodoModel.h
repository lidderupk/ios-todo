//
//  SFTodoModel.h
//  TodoListApp
//
//  Created by Upkar Lidder on 2014-01-26.
//  Copyright (c) 2014 8indaas. All rights reserved.
//

#import <Parse/Parse.h>
#import <Foundation/Foundation.h>

@interface SFTodoModel : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

@property (retain) NSString *itemText;
@property (nonatomic, assign) NSInteger position;
@property (nonatomic, assign) BOOL isDone;

@end
