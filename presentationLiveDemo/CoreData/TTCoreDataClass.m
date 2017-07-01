//
//  TTCoreDataClass.m
//  presentationLiveDemo
//
//  Created by tc on 6/29/17.
//  Copyright © 2017 ZYH. All rights reserved.
//

#import "TTCoreDataClass.h"

#import <CoreData/CoreData.h>

#define entityName @"PlatformModel"
#define dbName @"Platform"
static  TTCoreDataClass * _instance;

@implementation TTCoreDataClass
- (void)creatDatabase
{
    //    1、创建模型对象
    //    获取模型路径
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:dbName withExtension:@"momd"];
    //根据模型文件创建模型对象
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    //2、创建持久化助理
    //利用模型对象创建助理对象
    NSPersistentStoreCoordinator *store = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    //数据库的名称和路径
    NSString *docStr = [self dbFilePath];
    NSString *sqlPath = [docStr stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",dbName]];
    
    NSURL *sqlUrl = [NSURL fileURLWithPath:sqlPath];
    
   
    //设置数据库相关信息
    NSError * error;
    [store addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:sqlUrl options:nil error:&error];
    if (error) {
                NSLog(@"创建数据库失败 error:%@",error);
    }
    else
    {
                NSLog(@"创建数据库成功 sqlUrl:%@",sqlUrl);
    }
    
    
    //3、创建上下文
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    
    //关联持久化助理
    [context setPersistentStoreCoordinator:store];
    _context = context;
}

- (long long)getDbFileSize
{
    NSString *sqlPath = [[self dbFilePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",dbName]];
    return [self fileSizeAtPath:sqlPath];
}

- ( long long )fileSizeAtPath:( NSString *) filePath{
    NSFileManager * manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath :filePath error : nil] fileSize];
    }
    return 0;
}


- (void)cleanUpAllData
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *documentsPath = [self dbFilePath];
    
    //沙盒中三个文件
    NSString *filePath1 = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",dbName]];
    NSString *filePath2 = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db-shm",dbName]];
    NSString *filePath3 = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db-wal",dbName]];
    
    NSError *error;
    
    BOOL success = [fileManager removeItemAtPath:filePath1 error:&error];
    [fileManager removeItemAtPath:filePath2 error:nil];
    [fileManager removeItemAtPath:filePath3 error:nil];
    
    if (success)
    {
        [self creatDatabase];
        //清除内存中的缓存
        //        [self.context.persistentStoreCoordinator removePersistentStore:self.context.persistentStoreCoordinator.persistentStores[0] error:nil];
        //        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:dbName withExtension:@"momd"];
        //        [self.context.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:modelURL options:nil error:nil];
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}

- (BOOL)updatePlatformWithName:(NSString *)name rtmp:(NSString * )rtmp streamKey:(NSString *)streamKey customString:(NSString *)customString enabel:(BOOL)enable selected:(BOOL)isSelected
{
    //    1.创建NSFetchRequest查询请求对象
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    //    2.设置需要查询的实体描述NSEntityDescription
    NSEntityDescription *desc = [NSEntityDescription entityForName:entityName
                                            inManagedObjectContext:self.context];
    request.entity = desc;
    //    3.设置排序顺序NSSortDescriptor对象集合(可选)
//    request.sortDescriptors = descriptorArray;
    NSString * filterStr = [NSString stringWithFormat:@"name == '%@'",name];
    //    4.设置条件过滤（可选）
    NSPredicate *predicate = [NSPredicate predicateWithFormat:filterStr];
    request.predicate = predicate;
    NSError * error1;
    // NSManagedObject对象集合
    NSArray *objs = [self.context executeFetchRequest:request error:&error1];
    if (error1) {
        NSLog(@"error1:%@",error1);
    }
    
    
    // 查询结果数目
    NSUInteger count = objs.count;
    //如果存在  则更新
    if (count>0)
    {
        PlatformModel * model = [objs firstObject];
        model.rtmp = rtmp;
        model.streamKey = streamKey;
        model.isEnable = enable;
        model.customString = customString;
        model.isSelected = isSelected;
    }
    //如果不存在   则添加
    else
    {
        
        //    1.根据Entity名称和NSManagedObjectContext获取一个新的NSManagedObject
        PlatformModel *newEntity = [NSEntityDescription
                                      insertNewObjectForEntityForName:entityName
                                      inManagedObjectContext:self.context];
        //    2.根据Entity中的键值，一一对应通过setValue:forkey:给NSManagedObject对象赋值
        newEntity.name = name;
        newEntity.rtmp = rtmp;
        newEntity.streamKey = streamKey;
        newEntity.isEnable = enable;
        newEntity.customString = customString;
        newEntity.isSelected = isSelected;
    }
    
        //    3.保存修改
    NSError *error = nil;
    BOOL result = [self.context save:&error];
    if (error) {
        NSLog(@"插入数据失败： %@",error);
    }
    return result;
}

- (NSArray *)localAllPlatforms
{
    //    1.创建NSFetchRequest查询请求对象
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    //    2.设置需要查询的实体描述NSEntityDescription
    NSEntityDescription *desc = [NSEntityDescription entityForName:entityName
                                            inManagedObjectContext:self.context];
    request.entity = desc;
    //    3.设置排序顺序NSSortDescriptor对象集合(可选)
    //   request.sortDescriptors = descriptorArray;
//    NSString * filterStr = [NSString stringWithFormat:@"newsid = %@",newsid];
    //    4.设置条件过滤（可选）
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:filterStr];
//    request.predicate = predicate;
    //    5.执行查询请求
    NSError *error = nil;
    // NSManagedObject对象集合
    NSArray *objs = [self.context executeFetchRequest:request error:&error];
    
    // 查询结果数目
    return objs;
}


- (PlatformModel *)localSelectedPlatform
{
    //    1.创建NSFetchRequest查询请求对象
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    //    2.设置需要查询的实体描述NSEntityDescription
    NSEntityDescription *desc = [NSEntityDescription entityForName:entityName
                                            inManagedObjectContext:self.context];
    request.entity = desc;
    
    NSString * filterStr = [NSString stringWithFormat:@"isSelected = 1"];
    //    4.设置条件过滤（可选）
    NSPredicate *predicate = [NSPredicate predicateWithFormat:filterStr];
    request.predicate = predicate;
    //    5.执行查询请求
    NSError *error = nil;
    // NSManagedObject对象集合
    NSArray *objs = [self.context executeFetchRequest:request error:&error];
    // 查询结果
    if (objs)
    {
        return [objs firstObject];
    }
    else
    {
        return nil;
    }
    
}

- (void)setlocalSelectedPlatformName:(NSString *)platformName
{
    //    1.创建NSFetchRequest查询请求对象
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    //    2.设置需要查询的实体描述NSEntityDescription
    NSEntityDescription *desc = [NSEntityDescription entityForName:entityName
                                            inManagedObjectContext:self.context];
    request.entity = desc;
    
    //    5.执行查询请求
    NSError *error = nil;
    // NSManagedObject对象集合
    NSArray *objs = [self.context executeFetchRequest:request error:&error];
    [objs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PlatformModel * model = obj;
        if ([model.name isEqualToString:platformName]) {
            model.isSelected = YES;
        }
        else
        {
            model.isSelected = NO;
        }
    }];
    NSError * saveError;
    [self.context save:&saveError];
    if (saveError) {
        NSLog(@"saveError:%@",saveError);
    }
    
}

#pragma mark - getter
- (NSManagedObjectContext *)context
{
    if (!_context) {
        [self creatDatabase];
    }
    return _context;
}

- (NSString *)dbFilePath
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark - 单例
+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [TTCoreDataClass shareInstance];
}

- (instancetype)copy
{
    return [TTCoreDataClass shareInstance];
}

@end
