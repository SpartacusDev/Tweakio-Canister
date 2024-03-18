#import "Tweak.h"


%subclass TWCanisterApi : TWBaseApi

- (instancetype)init {
    self = %orig;
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

- (void)search:(NSString *)query completionHandler:(void (^)(NSArray<Result *> *, NSError *))completionHandler {
    query = [query stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    NSURL *api = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://api.canister.me/v2/jailbreak/package/search?q=%@", query]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *request = [NSURLRequest requestWithURL:api];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse *response, NSError *err){
        if (err) {
            completionHandler(nil, err);
            return;
        }

        if (!data) {
            completionHandler(nil, [[NSError alloc] initWithDomain:@"com.spartacus.tweakio.canister" code:1 userInfo:@{   
                NSLocalizedDescriptionKey: @"Failed to retrieve data",
                NSLocalizedFailureReasonErrorKey: @"Failed to retrive data from Canister",
            }]);
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
        completionHandler([resultsArray copy], nil);
    }];
    [task resume];
}

%end