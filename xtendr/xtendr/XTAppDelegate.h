//
//  XTAppDelegate.h
//  xtendr
//
//  Created by Tony Million on 18/08/2012.
//  Copyright (c) 2012 Tony Million. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XTAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
