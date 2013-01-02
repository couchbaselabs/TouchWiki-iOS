//
//  WikiPage.m
//  TouchWiki
//
//  Created by Jens Alfke on 12/14/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import "WikiPage.h"
#import "Wiki.h"

@implementation WikiPage


- (id) initNewWithTitle: (NSString*)title inWiki: (Wiki*)wiki {
    TDDocument* doc = [wiki.database documentWithID: [wiki docIDForPageWithTitle: title]];
    self = [super initWithDocument: doc];
    if (self) {
        [self setValue: @"page" ofProperty: @"type"];
        [self setValue: wiki.wikiID ofProperty: @"wiki_id"];
        self.created_at = self.updated_at = [NSDate date];
    }
    return self;
}


- (NSString*) title {
    NSString *wikiID, *title;
    if (![[self class] parseDocID: self.document.documentID intoWikiID: &wikiID andTitle: &title])
        return @"???";
    return title;
}


- (Wiki*) wiki {
    NSString *wikiID, *title;
    __unused bool ok = [[self class] parseDocID: self.document.documentID intoWikiID: &wikiID andTitle: &title];
    NSAssert(ok, @"Invalid doc ID");
    TDDocument* doc = [self.database documentWithID: wikiID];
    return doc ? [Wiki modelForDocument: doc] : nil;
}


- (NSString*) description {
    return [NSString stringWithFormat: @"%@[%@ / '%@'", self.class, self.wiki.title, self.title];
}


+ (bool) parseDocID: (NSString*)docID
         intoWikiID: (NSString**)outWikiID
           andTitle: (NSString**)outTitle
{
    NSRange colon = [docID rangeOfString: @":"];
    if (colon.length == 0)
        return false;
    *outWikiID = [docID substringToIndex: colon.location];
    *outTitle = [docID substringFromIndex: NSMaxRange(colon)];
    return (*outWikiID).length > 0 && (*outTitle).length > 0;
}


- (Wiki*) newWikiWithTitle: (NSString*)pageTitle {
    return [[Wiki alloc] initNewWithTitle: pageTitle inDatabase: self.database];
}


@end
