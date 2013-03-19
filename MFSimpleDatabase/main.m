//
//  main.m
//  MFSimpleDatabase
//
//  Created by Latermoon on 13-3-18.
//  Copyright (c) 2013年 Latermoon.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MFAppDelegate.h"
#import "MFSimpleDatabase.h"

// return UIApplicationMain(argc, argv, nil, NSStringFromClass([MFAppDelegate class]));
int main(int argc, char *argv[])
{
    @autoreleasepool {
        NSLog(@"No UI...");
        
        MFSimpleDatabase *db = [MFSimpleDatabase databaseWithPath:@""];
        [db executeUpdate:@"create table t1(name text, score integer)"];
        
        MFDbCollection *coll = [db collection:@"t1"];
        
        NSDictionary *row1 = [NSDictionary dictionaryWithObjectsAndKeys:@"A", @"name", [NSNumber numberWithInt:91], @"score", nil];
        [coll insert:row1];
        
        NSDictionary *row2 = [NSDictionary dictionaryWithObjectsAndKeys:@"B", @"name", [NSNumber numberWithInt:92], @"score", nil];
        [coll insert:row2];
        
        MFDbList *list = [coll find];
        for (MFDbRow *row in list) {
            NSLog(@"%@", row);
        }
        
        MFDbRow *row3 = [coll findOne:@"name='A'" fields:@[@"name", @"score"]];
        NSLog(@"findOne %@", row3);
        
        NSLog(@"Finish");
    }
}
