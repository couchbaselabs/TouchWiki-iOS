//
//  WikiPage.m
//  TouchWiki
//
//  Created by Jens Alfke on 12/14/12.
//  Copyright (c) 2012 Couchbase. All rights reserved.
//

#import "WikiPage.h"
#import "Wiki.h"
#import "WikiStore.h"


@interface WikiPage ()
@property (readwrite, copy) NSString* updated_by;
@end


@implementation WikiPage


@dynamic draft, updated_by;

@synthesize selectedRange=_selectedRange;


- (id) initNewWithTitle: (NSString*)title inWiki: (Wiki*)wiki {
    CBLDocument* doc = [wiki.database documentWithID: [wiki docIDForPageWithTitle: title]];
    self = [super initWithDocument: doc];
    if (self) {
        [self setupType: @"page"];
        [self setValue: wiki.wikiID ofProperty: @"wiki_id"];
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
    CBLDocument* doc = [self.database documentWithID: wikiID];
    return doc ? [Wiki modelForDocument: doc] : nil;
}


- (NSString*) description {
    return [NSString stringWithFormat: @"%@[%@/'%@']", self.class, self.wiki.title, self.title];
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


- (NSTimeInterval) autosaveDelay {
    return 30.0;
}


- (bool) editable {
    return self.wiki.editable;
}


- (bool) owned {
    return self.wiki.owned;
}


- (NSDictionary*) propertiesToSave {
    if (self.needsSave) {
        // Set updated_by when saving:
        self.updated_by = self.wikiStore.username;
    }
    return [super propertiesToSave];
}


@end
