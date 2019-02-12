//
//  AppDelegate.m
//  voucher_swap
//
//  Created by Brandon Azad on 12/7/18.
//  Copyright © 2018 Brandon Azad. All rights reserved.
//

#import <sys/spawn.h>
#import "AppDelegate.h"

#import "voucher_swap.h"
#import "kernel_call.h"
#import "kernel_call/user_client.h"
#import "log.h"

void execu(const char* path, int argc, ...) {
  va_list ap;
  va_start(ap, argc);

  const char ** argv = malloc(argc+2);
  argv[0] = path;
  for (int i = 1; i <= argc; i++) {
    argv[i] = va_arg(ap, const char*);
  }
  va_end(ap);
  argv[argc+1] = NULL;

  posix_spawn(NULL, path, NULL, NULL, (char *const*)argv, NULL);
  free(argv);
}

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	voucher_swap();
	bool ok = kernel_call_init();
	if (!ok) {
		exit(1);
	}

  INFO("about to unlock nvram");
  unlocknvram();

  uint64_t ucred_field, ucred;
  assume_kernel_credentials(&ucred_field, &ucred);
//  execu("/usr/sbin/ioreg", 2, "-flip", "IODeviceTree");
  execu("/usr/sbin/nvram", 1, "com.apple.System.boot-nonce=0x1111111111111111");
  execu("/usr/sbin/nvram", 1, "-p");
  restore_credentials(ucred_field, ucred);
  sleep(2);

  locknvram();
	kernel_call_deinit();
	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
