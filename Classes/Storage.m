#import "Storage.h"

@implementation Storage

	static sqlite3 *database = nil;
	+ (NSString*) dbStoragePath; {
		return [@"~/Documents/Storage.db" stringByExpandingTildeInPath];
	}
	
	+ (sqlite3 *) database; {
		if (!database) {
			char* error = nil;
			sqlite3_open([[self dbStoragePath] UTF8String], &database);
			sqlite3_exec(database, [@"CREATE TABLE IF NOT EXISTS searches (string TEXT)" UTF8String], NULL, NULL, &error);
		}
		return database;
	}

	+ (void) removeItemsFromTable: (NSString*) tableName; {
		sqlite3_stmt* statement = nil;
		if (!statement) {
			sqlite3_prepare_v2(database, [[NSString stringWithFormat: @"DELETE FROM %@", tableName] UTF8String], -1, &statement, NULL);
		}
		if (statement) {
			int success = sqlite3_step(statement);
			if (success == SQLITE_DONE) {
			}
			sqlite3_reset(statement);
			sqlite3_finalize(statement);
		}
	}

	+ (void) clearSearchHistory; {
		[Storage removeItemsFromTable: @"searches"];
	}

	static Storage *instance = nil;
	static int kStorage = -1;
	+ (Storage *) instance; {
		if (kStorage < 0) {
			kStorage = ([defaults boolForKey: @"kStorage"]) ? 1 : 0;
			if (kStorage == 0) {
				[Storage database];
			}
		}
		if (kStorage == 1) {
			if (!instance)
				instance = [[Storage alloc] init];
			return instance;
		}
		return nil;
	}

#pragma mark -

	- (void) storeSearch: (NSString *)searchString; {
		if (!EmptyString(searchString)) {
			static sqlite3_stmt* statement = nil;
			if (!statement) {
				char *sql = "INSERT INTO searches (string) VALUES(?)";
				sqlite3_prepare_v2([Storage database], sql, -1, &statement, NULL);
			}
			if (statement) {
				sqlite3_bind_text(statement, 1, [[searchString trimmedString] UTF8String], -1, SQLITE_STATIC);
				
				int success = sqlite3_step(statement);
				if (success == SQLITE_DONE) {
					
				}				
				sqlite3_reset(statement);
			}
		}
	}

	- (void) storeResult: (Result *)result; {
		
	}

	- (void) removeItem:(NSString *) theString; {
		sqlite3_stmt* statement = nil;
        sqlite3_prepare_v2(database, [[NSString stringWithFormat: @"DELETE FROM searches WHERE string LIKE \"%@\"", theString] UTF8String], -1, &statement, NULL);
        if (statement) {
            int success = sqlite3_step(statement);
            if (success == SQLITE_DONE) {
            }
            sqlite3_reset(statement);
            sqlite3_finalize(statement);
        }
	}

#pragma mark -

	- (void) _insertString:(NSString *) theString intoArray: (NSMutableArray*) theArray; {
		for (NSString *existingString in theArray) {
			if ([existingString isEqual:theString]) {
				return;
			}
		}
		[theArray addObject: theString];
	}

	- (NSMutableArray*) recentHistory; {
		NSMutableArray* historyArray = [NSMutableArray array];
		
		static sqlite3_stmt* statement = nil;
		if (!statement) {
			char* sql = "SELECT * FROM searches LIMIT 50";
			sqlite3_prepare_v2([[self class] database], sql, -1, &statement, NULL);
		}
		
		if (statement) {
			while (sqlite3_step(statement) == SQLITE_ROW && [historyArray count] < 30) {
				NSString *searchQuery = [NSString stringWithCString: (char*)sqlite3_column_text(statement, 0)];				
				[self _insertString:searchQuery intoArray:historyArray];
			}
			sqlite3_reset(statement);
		}
		if([historyArray count])
			[historyArray reverse];
		return historyArray;
	}

@end
