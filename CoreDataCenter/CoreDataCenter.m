//
//  CoreDataCenter.m
//  
//
//  Created by Daniel on 15/10/15.
//
//

#import "CoreDataCenter.h"
#import "ZYPot.h"

static CoreDataCenter *coreDataCenter;

@implementation CoreDataCenter

+ (CoreDataCenter *)shareCoreDataCenter {
    
    dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coreDataCenter = [[CoreDataCenter alloc] init];
    });
    return coreDataCenter;
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.jollyKnows.CoreDataTest" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CoreDataTest" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CoreDataTest.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark -- 增删改查

- (NSMutableArray *)searchDataWithEntityName:(NSString *)entityName sort:(NSString *)sort ascending:(BOOL)ascending {
    return [self searchDataWithEntityName:entityName sort:sort ascending:ascending batchSize:0 limit:0 offset:0];
}

// 检索
- (NSMutableArray *)searchDataWithEntityName:(NSString *)entityName
                                        sort:(NSString *)sort
                                   ascending:(BOOL)ascending
                                   batchSize:(NSInteger)batchSize
                                       limit:(NSInteger)limit
                                      offset:(NSInteger)offset {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (batchSize) {
        [request setFetchBatchSize:batchSize];//从数据库里每次加载 batchSize 条数据来筛选数据
    }
    
    if (limit) {
        [request setFetchLimit:limit];
    }
    
    if (offset) {
        [request setFetchOffset:offset];
    }
    
    //设置检索类型
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:coreDataCenter.managedObjectContext];
    [request setEntity:entity];
    
    //设置排序方式
    if (sort) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sort ascending:ascending];
        NSArray *sortDescriptorArr = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [request setSortDescriptors:sortDescriptorArr];
    }
    
    //执行请求
    NSError *error = nil;
    NSMutableArray *fetchResult = [[coreDataCenter.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (fetchResult == nil) {
        NSLog(@"检索失败%@", error);
        return nil;
    }
    
    return fetchResult;
}

// 保存
- (BOOL)saveData:(NSArray<NSDictionary *>*)dataArr entityName:(NSString *)entityName {
    
    for (NSDictionary *dic in dataArr) {
        NSManagedObject *obj = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:coreDataCenter.managedObjectContext];
        
        [obj setValuesWithDic:dic];
    }
    
    NSError *error = nil;
    BOOL isSave = [coreDataCenter.managedObjectContext save:&error];
    
    if (isSave) {
        NSLog(@"保存成功");
    } else {
        NSLog(@"保存失败:%@", error);
    }
    return isSave;
}

// 删除

- (BOOL)deleteDataWithModel:(NSManagedObject *)obj {
    [coreDataCenter.managedObjectContext deleteObject:obj];
    
    NSError *error = nil;
    BOOL isSave = [coreDataCenter.managedObjectContext save:&error];if (isSave) {
        NSLog(@"保存成功");
    } else {
        NSLog(@"保存失败:%@", error);
    }
    return isSave;
}

- (BOOL)deleteDataWithEntityName:(NSString *)entityName {
    
    NSArray *models = [self searchDataWithEntityName:entityName sort:nil ascending:YES];
    
    for (NSManagedObject *obj in models) {
        [coreDataCenter.managedObjectContext deleteObject:obj];
    }
    
    NSError *error = nil;
    BOOL isSave = [coreDataCenter.managedObjectContext save:&error];
    if (isSave) {
        NSLog(@"保存成功");
    } else {
        NSLog(@"保存失败:%@", error);
    }
    return isSave;
}

#pragma mark -- 字典数组转模型数组

- (NSArray *)modelsWithDataArr:(NSArray *)dataArr entityName:(NSString *)entityName {
    
    NSMutableArray *models = @[].mutableCopy;
    for (NSDictionary *dic in dataArr) {
        NSManagedObject *obj = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:coreDataCenter.managedObjectContext];
        [obj setValuesWithDic:dic];
    }
    
    return models;
}


@end
