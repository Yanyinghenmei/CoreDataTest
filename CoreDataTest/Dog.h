//
//  Dog.h
//  
//
//  Created by Daniel on 15/10/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Dog : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSNumber * sex;

@end
