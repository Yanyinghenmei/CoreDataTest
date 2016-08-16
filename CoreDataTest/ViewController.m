//
//  ViewController.m
//  CoreDataTest
//
//  Created by Daniel on 15/10/15.
//  Copyright (c) 2015年 Daniel. All rights reserved.
//

#import "ViewController.h"
#import "Dog.h"
#import "CoreDataCenter.h"

@interface ViewController ()

@end

@implementation ViewController {
    CoreDataCenter *coreDataCenter;
    NSMutableArray *dogsArr;
    UITextView *textView;
}

- (void)viewDidLoad {
    coreDataCenter = [CoreDataCenter shareCoreDataCenter];
    dogsArr = [NSMutableArray array];
    
    [super viewDidLoad];
    
    [self creatUI];
    
    [self saveData];
//    [self deleteData];
    [self searchData];
}

// 检索
- (void)searchData {
    dogsArr = [coreDataCenter searchDataWithEntityName:@"Dog" sort:nil ascending:YES];
    
    //显示数据
    if (dogsArr.count) {
        Dog *dog = dogsArr.lastObject;
        textView.text = [NSString stringWithFormat:@"name:%@\nage:%@\nsex:%@", dog.name, dog.age, dog.sex];
    }
}

// 保存
- (void)saveData {
    
    NSDictionary *dic = @{@"name":@"dog",
                          @"age":@4,
                          @"sex":@YES};
    
    [coreDataCenter saveData:@[dic] entityName:@"Dog"];
    
}

// 删除
- (void)deleteData {
    [coreDataCenter deleteDataWithEntityName:@"Dog"];
}

- (void)creatUI {
    textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 300, self.view.frame.size.width-20, 200)];
    textView.textAlignment = NSTextAlignmentCenter;
    textView.font = [UIFont systemFontOfSize:24];
    [self.view addSubview:textView];
}


@end
