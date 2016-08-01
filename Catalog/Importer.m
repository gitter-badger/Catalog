//
//  Importer.m
//  Catalog
//
//  Created by Ignacio H. Gomez on 7/30/16.
//  Copyright © 2016 Ignacio H. Gomez. All rights reserved.
//

#import "Importer.h"
#import "Article.h"

@interface Importer ()

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) ArticlesService *webservice;
@property (nonatomic) int batchCount;
@end

@implementation Importer

- (id)initWithContext:(NSManagedObjectContext *)context webservice:(ArticlesService *)webservice {
	self = [super init];
	if (self) {
		self.context = context;
		self.webservice = webservice;
	}
	return self;
}

- (void)import {
	self.batchCount = 0;
	[self.webservice fetchAllArticles:^(NSArray *articles) {
		[self.context performBlock:^ {
			for(NSDictionary *podSpec in articles) {
				NSString *identifier = podSpec[@"id"];
				Article *article = [Article findOrCreatePodWithIdentifier:identifier inContext:self.context];
				[article loadFromDictionary:podSpec];
			}
				//self.batchCount++;
				//if (self.batchCount % 10 == 0) {
				NSError *error = nil;
				[self.context save:&error];
				if (error) {
					NSLog(@"Error: %@", error.localizedDescription);
						//}
			}
		}];
	}];
}

@end
