//
//  CoreDataCenter.h
//  
//
//  Created by Daniel on 15/10/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataCenter : NSObject
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (CoreDataCenter *)shareCoreDataCenter;

- (void)saveContext;

/**
 *  查询数据库
 *  @param entityName      实体名称
 *  @param sort            根据此属性排序
 *  @param ascending       升序/降序
 *  @return 模型数组
 */
- (NSMutableArray *)searchDataWithEntityName:(NSString *)entityName
                                        sort:(NSString *)sort
                                   ascending:(BOOL)ascending;

- (NSMutableArray *)searchDataWithEntityName:(NSString *)entityName
                                        sort:(NSString *)sort
                                   ascending:(BOOL)ascending
                                   batchSize:(NSInteger)batchSize
                                       limit:(NSInteger)limit
                                      offset:(NSInteger)offset;


/**
 *  保存
 *  @param models     字典数组
 *  @param entityName 实体名称
 *  @return 是否保存成功
 */
- (BOOL)saveData:(NSArray<NSDictionary *>*)dataArr entityName:(NSString *)entityName;

// 删除
- (BOOL)deleteDataWithModel:(NSManagedObject *)obj;
- (BOOL)deleteDataWithEntityName:(NSString *)entityName;

// 字典数组––>模型数组
- (NSArray *)modelsWithDataArr:(NSArray *)dataArr entityName:(NSString *)entityName;

@end
