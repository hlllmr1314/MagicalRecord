    //
//  NSManagedObject+MagicalFinders.m
//  Magical Record
//
//  Created by Saul Mora on 3/7/12.
//  Copyright (c) 2012 Magical Panda Software LLC. All rights reserved.
//

#import "NSManagedObject+MagicalFinders.h"
#import "NSManagedObject+MagicalRequests.h"
#import "NSManagedObject+MagicalRecord.h"
#import "NSManagedObjectContext+MagicalThreading.h"

@implementation NSManagedObject (MagicalFinders)

#pragma mark - Finding Data


+ (NSArray *) MR_findAllInContext:(NSManagedObjectContext *)context
{
	return [self MR_executeFetchRequest:[self MR_requestAllInContext:context] inContext:context];
}

+ (NSArray *) MR_findAll
{
	return [self MR_findAllInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (NSArray *) MR_findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [self MR_requestAllSortedBy:sortTerm ascending:ascending inContext:context];
	
	return [self MR_executeFetchRequest:request inContext:context];
}

+ (NSArray *) MR_findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending
{
	return [self MR_findAllSortedBy:sortTerm
                          ascending:ascending 
                          inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (NSArray *) MR_findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [self MR_requestAllSortedBy:sortTerm
                                                ascending:ascending
                                            withPredicate:searchTerm
                                                inContext:context];
	
	return [self MR_executeFetchRequest:request inContext:context];
}

+ (NSArray *) MR_findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm
{
	return [self MR_findAllSortedBy:sortTerm
                          ascending:ascending
                      withPredicate:searchTerm 
                          inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}


+ (NSArray *) MR_findAllWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [self MR_createFetchRequestInContext:context];
	[request setPredicate:searchTerm];
	
	return [self MR_executeFetchRequest:request
                              inContext:context];
}

+ (NSArray *) MR_findAllWithPredicate:(NSPredicate *)searchTerm
{
	return [self MR_findAllWithPredicate:searchTerm
                               inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (id) MR_selectAttribute:(NSString *)attribute ascending:(BOOL)ascending;
{
    return [self MR_selectAttribute:attribute ascending:ascending inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (id) MR_selectAttribute:(NSString *)attribute ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context;
{
    NSFetchRequest *request = [self MR_requestAllSortedBy:attribute ascending:ascending inContext:context];
    [request setResultType:NSDictionaryResultType];
    [request setPropertiesToFetch:[NSArray arrayWithObject:attribute]];
    NSArray *results = [self MR_executeFetchRequest:request inContext:context];

    return [results valueForKeyPath:[NSString stringWithFormat:@"@unionOfObjects.%@", attribute]];
}

+ (id) MR_findFirstInContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [self MR_createFetchRequestInContext:context];
	
	return [self MR_executeFetchRequestAndReturnFirstObject:request inContext:context];
}

+ (id) MR_findFirst
{
	return [self MR_findFirstInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (id) MR_findFirstByAttribute:(NSString *)attribute withValue:(id)searchValue inContext:(NSManagedObjectContext *)context
{	
	NSFetchRequest *request = [self MR_requestFirstByAttribute:attribute withValue:searchValue inContext:context];
    //    [request setPropertiesToFetch:[NSArray arrayWithObject:attribute]];
    
	return [self MR_executeFetchRequestAndReturnFirstObject:request inContext:context];
}

+ (id) MR_findFirstByAttribute:(NSString *)attribute withValue:(id)searchValue
{
	return [self MR_findFirstByAttribute:attribute
                               withValue:searchValue 
                               inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (id) MR_findFirstByAttribute:(NSString *)attribute withValue:(id)searchValue orderedBy:(NSString *)orderedBy ascending:(BOOL)ascending;
{
    return [self MR_findFirstByAttribute:attribute withValue:searchValue orderedBy:orderedBy ascending:ascending inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (id) MR_findFirstByAttribute:(NSString *)attribute withValue:(id)searchValue orderedBy:(NSString *)orderedBy ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context;
{
    NSFetchRequest *request = [self MR_requestFirstByAttribute:attribute withValue:searchValue inContext:context];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:orderedBy ascending:ascending];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    return [self MR_executeFetchRequestAndReturnFirstObject:request inContext:context];
}

+ (id) MR_findFirstOrderedByAttribute:(NSString *)attribute ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context;
{
    NSFetchRequest *request = [self MR_requestAllSortedBy:attribute ascending:ascending inContext:context];
    [request setFetchLimit:1];

    return [self MR_executeFetchRequestAndReturnFirstObject:request inContext:context];
}

+ (id) MR_findFirstOrderedByAttribute:(NSString *)attribute ascending:(BOOL)ascending;
{
    return [self MR_findFirstOrderedByAttribute:attribute
                                      ascending:ascending
                                      inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (id) MR_findLargestValueForAttribute:(NSString *)attribute withPredicate:(NSPredicate *)predicate;
{
    return [self MR_findLargestValueForAttribute:attribute withPredicate:predicate inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (id) MR_findLargestValueForAttribute:(NSString *)attribute withPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;
{
    NSFetchRequest *request = [self MR_requestAllSortedBy:attribute ascending:NO inContext:context];
    [request setFetchLimit:1];
    [request setResultType:NSDictionaryResultType];
    [request setPropertiesToFetch:@[attribute]];
    [request setPredicate:predicate];

    NSDictionary *results = [self MR_executeFetchRequestAndReturnFirstObject:request inContext:context];
    id value = [results valueForKey:attribute];

    return value;
}

+ (id) MR_findLargestValueForAttribute:(NSString *)attribute;
{
    return [self MR_findLargestValueForAttribute:attribute inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (id) MR_findLargestValueForAttribute:(NSString *)attribute inContext:(NSManagedObjectContext *)context;
{
    return [self MR_findLargestValueForAttribute:attribute withPredicate:nil inContext:context];
}

+ (id) MR_findSmallestValueForAttribute:(NSString *)attribute;
{
    return [self MR_findSmallestValueForAttribute:attribute inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (id) MR_findSmallestValueForAttribute:(NSString *)attribute inContext:(NSManagedObjectContext *)context;
{
    NSFetchRequest *request = [self MR_requestAllSortedBy:attribute ascending:YES inContext:context];
    [request setFetchLimit:1];
    [request setResultType:NSDictionaryResultType];
    [request setPropertiesToFetch:@[attribute]];

    NSDictionary *results = [self MR_executeFetchRequestAndReturnFirstObject:request inContext:context];
    id value = [results valueForKey:attribute];

    return value;
}

+ (id) MR_findFirstWithPredicate:(NSPredicate *)searchTerm
{
    return [self MR_findFirstWithPredicate:searchTerm inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (id) MR_findFirstWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self MR_requestFirstWithPredicate:searchTerm inContext:context];
    
    return [self MR_executeFetchRequestAndReturnFirstObject:request inContext:context];
}

+ (id) MR_findFirstWithPredicate:(NSPredicate *)searchterm sortedBy:(NSString *)property ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [self MR_requestAllSortedBy:property ascending:ascending withPredicate:searchterm inContext:context];
    
	return [self MR_executeFetchRequestAndReturnFirstObject:request inContext:context];
}

+ (id) MR_findFirstWithPredicate:(NSPredicate *)searchterm sortedBy:(NSString *)property ascending:(BOOL)ascending
{
	return [self MR_findFirstWithPredicate:searchterm
                                  sortedBy:property 
                                 ascending:ascending 
                                 inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (id) MR_findFirstWithPredicate:(NSPredicate *)searchTerm andRetrieveAttributes:(NSArray *)attributes inContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [self MR_createFetchRequestInContext:context];
	[request setPredicate:searchTerm];
	[request setPropertiesToFetch:attributes];
	
	return [self MR_executeFetchRequestAndReturnFirstObject:request inContext:context];
}

+ (id) MR_findFirstWithPredicate:(NSPredicate *)searchTerm andRetrieveAttributes:(NSArray *)attributes
{
	return [self MR_findFirstWithPredicate:searchTerm
                     andRetrieveAttributes:attributes 
                                 inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (id) MR_findFirstWithPredicate:(NSPredicate *)searchTerm sortedBy:(NSString *)sortBy ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context andRetrieveAttributes:(id)attributes, ...
{
	NSFetchRequest *request = [self MR_requestAllSortedBy:sortBy
                                                ascending:ascending
                                            withPredicate:searchTerm
                                                inContext:context];
	[request setPropertiesToFetch:[self MR_propertiesNamed:attributes]];
	
	return [self MR_executeFetchRequestAndReturnFirstObject:request inContext:context];
}

+ (id) MR_findFirstWithPredicate:(NSPredicate *)searchTerm sortedBy:(NSString *)sortBy ascending:(BOOL)ascending andRetrieveAttributes:(id)attributes, ...
{
	return [self MR_findFirstWithPredicate:searchTerm
                                  sortedBy:sortBy 
                                 ascending:ascending 
                                 inContext:[NSManagedObjectContext MR_contextForCurrentThread]
                     andRetrieveAttributes:attributes];
}

+ (NSArray *) MR_findByAttribute:(NSString *)attribute withValue:(id)searchValue inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self MR_requestAllWhere:attribute isEqualTo:searchValue inContext:context];
	
	return [self MR_executeFetchRequest:request inContext:context];
}

+ (NSArray *) MR_findByAttribute:(NSString *)attribute withValue:(id)searchValue
{
	return [self MR_findByAttribute:attribute
                          withValue:searchValue 
                          inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (NSArray *) MR_findByAttribute:(NSString *)attribute withValue:(id)searchValue andOrderBy:(NSString *)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context
{
	NSPredicate *searchTerm = [NSPredicate predicateWithFormat:@"%K = %@", attribute, searchValue];
	NSFetchRequest *request = [self MR_requestAllSortedBy:sortTerm ascending:ascending withPredicate:searchTerm inContext:context];
	
	return [self MR_executeFetchRequest:request inContext:context];
}

+ (NSArray *) MR_findByAttribute:(NSString *)attribute withValue:(id)searchValue andOrderBy:(NSString *)sortTerm ascending:(BOOL)ascending
{
	return [self MR_findByAttribute:attribute
                          withValue:searchValue
                         andOrderBy:sortTerm 
                          ascending:ascending 
                          inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}


#pragma mark -
#pragma mark NSFetchedResultsController helpers


#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

+ (NSString *) MR_fileCacheNameForObject:(id)object;
{
    SEL selector = @selector(fetchedResultsControllerCacheName);
    if ([object respondsToSelector:selector])
    {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[object methodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:object];
        [invocation invoke];
        NSString *returnValue = nil;
        [invocation getReturnValue:&returnValue];
        return returnValue;
    }
    return [NSString stringWithFormat:@"MagicalRecord-Cache-%@", NSStringFromClass([object class])];
}

+ (NSFetchedResultsController *) MR_fetchController:(NSFetchRequest *)request delegate:(id<NSFetchedResultsControllerDelegate>)delegate useFileCache:(BOOL)useFileCache groupedBy:(NSString *)groupKeyPath inContext:(NSManagedObjectContext *)context
{
    NSString *cacheName = useFileCache ? [self MR_fileCacheNameForObject:delegate] : nil;
    
	NSFetchedResultsController *controller =
        [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                            managedObjectContext:context
                                              sectionNameKeyPath:groupKeyPath
                                                       cacheName:cacheName];
    controller.delegate = delegate;
    
    return controller;
}

+ (NSFetchedResultsController *) MR_fetchAllGroupedBy:(NSString *)group withPredicate:(NSPredicate *)searchTerm sortedBy:(NSString *)sortTerm ascending:(BOOL)ascending delegate:(id<NSFetchedResultsControllerDelegate>)delegate inContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [self MR_requestAllSortedBy:sortTerm 
                                                ascending:ascending 
                                            withPredicate:searchTerm
                                                inContext:context];
    
    NSFetchedResultsController *controller = [self MR_fetchController:request 
                                                             delegate:delegate
                                                         useFileCache:NO
                                                            groupedBy:group
                                                            inContext:context];
    
    [self MR_performFetch:controller];
    return controller;
}

+ (NSFetchedResultsController *) MR_fetchAllGroupedBy:(NSString *)group withPredicate:(NSPredicate *)searchTerm sortedBy:(NSString *)sortTerm ascending:(BOOL)ascending delegate:(id)delegate
{
	return [self MR_fetchAllGroupedBy:group
                        withPredicate:searchTerm
                             sortedBy:sortTerm
                            ascending:ascending
                             delegate:delegate
                            inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (NSFetchedResultsController *) MR_fetchAllGroupedBy:(NSString *)group withPredicate:(NSPredicate *)searchTerm sortedBy:(NSString *)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context;
{
    return [self MR_fetchAllGroupedBy:group 
                        withPredicate:searchTerm
                             sortedBy:sortTerm
                            ascending:ascending
                             delegate:nil
                            inContext:context];
}

+ (NSFetchedResultsController *) MR_fetchAllGroupedBy:(NSString *)group withPredicate:(NSPredicate *)searchTerm sortedBy:(NSString *)sortTerm ascending:(BOOL)ascending 
{
    return [self MR_fetchAllGroupedBy:group 
                        withPredicate:searchTerm
                             sortedBy:sortTerm
                            ascending:ascending
                            inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}


+ (NSFetchedResultsController *) MR_fetchAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm groupBy:(NSString *)groupingKeyPath inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self MR_requestAllSortedBy:sortTerm
                                                ascending:ascending
                                            withPredicate:searchTerm
                                                inContext:context];
    
	NSFetchedResultsController *controller = [self MR_fetchController:request 
                                                             delegate:nil
                                                         useFileCache:NO
                                                            groupedBy:groupingKeyPath
                                                            inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    
    [self MR_performFetch:controller];
    return controller;
}

+ (NSFetchedResultsController *) MR_fetchAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm groupBy:(NSString *)groupingKeyPath;
{
    return [self MR_fetchAllSortedBy:sortTerm
                           ascending:ascending
                       withPredicate:searchTerm
                             groupBy:groupingKeyPath
                           inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (NSFetchedResultsController *) MR_fetchAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm groupBy:(NSString *)groupingKeyPath delegate:(id<NSFetchedResultsControllerDelegate>)delegate inContext:(NSManagedObjectContext *)context
{
	return [self MR_fetchAllGroupedBy:groupingKeyPath
                        withPredicate:searchTerm
                             sortedBy:sortTerm
                            ascending:ascending
                             delegate:delegate
                            inContext:context];
}

+ (NSFetchedResultsController *) MR_fetchAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm groupBy:(NSString *)groupingKeyPath delegate:(id<NSFetchedResultsControllerDelegate>)delegate
{
	return [self MR_fetchAllSortedBy:sortTerm 
                           ascending:ascending
                       withPredicate:searchTerm 
                             groupBy:groupingKeyPath 
                            delegate:delegate
                           inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

#endif

@end
