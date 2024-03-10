#import "Tweak.h"


@implementation TWCanisterApi

- (instancetype)init {
    self = [super init];
    if (self) {
        self.prefsValue = @"com.spartacus.tweakio.canister";
        self.name = @"Canister";
        self.apiDescription = @"Made by Aarnav Tale. Fast, used in Sileo and Zebra as a built-in feature, tells exact price for a package. Allows downloads for packages.";
        self.privacyPolicy = [NSURL URLWithString:@"https://canister.me/privacy"];
        self.tos = nil;
        self.options = nil;
    }
    return self;
}

- (void)search:(NSString *)query error:(NSError **)error completionHandler:(void (^)(NSArray<Result *> *))completionHandler {
    query = [query stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    NSURL *api = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://api.canister.me/v2/jailbreak/package/search?q=%@", query]];
    NSData *data = [NSData dataWithContentsOfURL:api];
    if (!data) {
        *error = [[NSError alloc] initWithDomain:@"com.spartacus.tweakio.canister" code:1 userInfo:@{   
            NSLocalizedDescriptionKey: @"Failed to retrieve data",
            NSLocalizedFailureReasonErrorKey: @"Failed to retrive data from Canister",
        }];
        return;
    }

    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
    NSMutableArray *resultsArray = [NSMutableArray array];

    for (NSDictionary *result in results[@"data"]) {
        NSString *iconURL;
        if (((NSObject *)result[@"icon"]).class == NSNull.class || [result[@"icon"] isEqual:@""] || [result[@"icon"] hasPrefix:@"file://"] || ((NSObject *)results[@"icon"]).class == NSNull.class) {
            iconURL = (NSString *)[NSNull null];
        }
        else
            iconURL = result[@"icon"];
        
        NSURL *downloadPath = [[NSURL URLWithString:result[@"repository"][@"uri"]] URLByAppendingPathComponent:result[@"filename"]];

        NSDictionary *data = @{
            @"name": result[@"name"],
            @"package": result[@"package"],
            @"version": result[@"version"],
            @"description": result[@"description"],
            @"author": result[@"author"] && ((NSObject *)result[@"author"]).class != NSNull.class ? result[@"author"] : @"UNKNOWN",
            @"price": result[@"price"],
            @"repo": [[%c(Repo) alloc] initWithURL:[NSURL URLWithString:result[@"repository"][@"uri"]] andName:result[@"repository"][@"key"]],
            @"icon url": iconURL.class == NSNull.class ? iconURL : [iconURL hasPrefix:@"http"] ? [NSURL URLWithString:iconURL] : [NSURL fileURLWithPath:iconURL],
            @"depiction": [result objectForKey:@"depiction"] && ((NSObject *)result[@"depiction"]).class != NSNull.class ? [NSURL URLWithString:result[@"depiction"]] ?: [NSURL URLWithString:@""] : [NSURL URLWithString:@""],
            @"section": result[@"section"],
            @"architecture": result[@"architecture"],
            @"filename": downloadPath
        };
        [resultsArray addObject:[[%c(Result) alloc] initWithDictionary:data]];
    }
    completionHandler([resultsArray copy]);
}

@end

%ctor {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    class_setSuperclass(TWCanisterApi.class, %c(TWBaseApi));
#pragma clang diagnostic pop
}