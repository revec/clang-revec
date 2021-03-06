// UNSUPPORTED: system-windows
// RUN: %clang_analyze_cc1 -fobjc-arc -analyzer-checker=core,osx.cocoa.RunLoopAutoreleaseLeak %s -triple x86_64-darwin -verify
// RUN: %clang_analyze_cc1 -DEXTRA=1 -DAP1=1 -fobjc-arc -analyzer-checker=core,osx.cocoa.RunLoopAutoreleaseLeak %s -triple x86_64-darwin -verify
// RUN: %clang_analyze_cc1 -DEXTRA=1 -DAP2=1 -fobjc-arc -analyzer-checker=core,osx.cocoa.RunLoopAutoreleaseLeak %s -triple x86_64-darwin -verify
// RUN: %clang_analyze_cc1 -DEXTRA=1 -DAP3=1 -fobjc-arc -analyzer-checker=core,osx.cocoa.RunLoopAutoreleaseLeak %s -triple x86_64-darwin -verify
// RUN: %clang_analyze_cc1 -DEXTRA=1 -DAP4=1 -fobjc-arc -analyzer-checker=core,osx.cocoa.RunLoopAutoreleaseLeak %s -triple x86_64-darwin -verify

#include "../Inputs/system-header-simulator-for-objc-dealloc.h"

#ifndef EXTRA

void just_runloop() { // No warning: no statements in between
  @autoreleasepool {
    [[NSRunLoop mainRunLoop] run]; // no-warning
  }
}

void just_xpcmain() { // No warning: no statements in between
  @autoreleasepool {
    xpc_main(); // no-warning
  }
}

void runloop_init_before() { // Warning: object created before the loop.
  @autoreleasepool {
    NSObject *object = [[NSObject alloc] init]; // expected-warning{{Temporary objects allocated in the autorelease pool followed by the launch of main run loop may never get released; consider moving them to a separate autorelease pool}}
    (void) object;
    [[NSRunLoop mainRunLoop] run]; 
  }
}

void xpcmain_init_before() { // Warning: object created before the loop.
  @autoreleasepool {
    NSObject *object = [[NSObject alloc] init]; // expected-warning{{Temporary objects allocated in the autorelease pool followed by the launch of xpc_main may never get released; consider moving them to a separate autorelease pool}}
    (void) object;
    xpc_main(); 
  }
}

void runloop_init_before_two_objects() { // Warning: object created before the loop.
  @autoreleasepool {
    NSObject *object = [[NSObject alloc] init]; // expected-warning{{Temporary objects allocated in the autorelease pool followed by the launch of main run loop may never get released; consider moving them to a separate autorelease pool}}
    NSObject *object2 = [[NSObject alloc] init]; // no-warning, warning on the first one is enough.
    (void) object;
    (void) object2;
    [[NSRunLoop mainRunLoop] run]; 
  }
}

void runloop_no_autoreleasepool() {
  NSObject *object = [[NSObject alloc] init]; // no-warning
  (void)object;
  [[NSRunLoop mainRunLoop] run];
}

void runloop_init_after() { // No warning: objects created after the loop
  @autoreleasepool {
    [[NSRunLoop mainRunLoop] run]; 
    NSObject *object = [[NSObject alloc] init]; // no-warning
    (void) object;
  }
}

#endif

#ifdef AP1
int main() {
    NSObject *object = [[NSObject alloc] init]; // expected-warning{{Temporary objects allocated in the autorelease pool of last resort followed by the launch of main run loop may never get released; consider moving them to a separate autorelease pool}}
    (void) object;
    [[NSRunLoop mainRunLoop] run]; 
    return 0;
}
#endif

#ifdef AP2
// expected-no-diagnostics
int main() {
  NSObject *object = [[NSObject alloc] init]; // no-warning
  (void) object;
  @autoreleasepool {
    [[NSRunLoop mainRunLoop] run]; 
  }
  return 0;
}
#endif

#ifdef AP3
// expected-no-diagnostics
int main() {
    [[NSRunLoop mainRunLoop] run];
    NSObject *object = [[NSObject alloc] init]; // no-warning
    (void) object;
    return 0;
}
#endif

#ifdef AP4
int main() {
    NSObject *object = [[NSObject alloc] init]; // expected-warning{{Temporary objects allocated in the autorelease pool of last resort followed by the launch of xpc_main may never get released; consider moving them to a separate autorelease pool}}
    (void) object;
    xpc_main();
    return 0;
}
#endif
