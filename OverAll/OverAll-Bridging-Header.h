#import <Foundation/Foundation.h>
#include <CoreGraphics/CoreGraphics.h>


extern unsigned int SLSMainConnectionID(void);
extern CGError SLSGetWindowBounds(unsigned int cid, uint32_t wid, CGRect *out_frame);
extern CGError SLSGetWindowOwner(unsigned int cid, uint32_t wid, int* out_cid);
extern CGError SLSGetWindowType(unsigned int cid, uint32_t wid, int* out_type);
extern CGError SLSGetWindowTags(unsigned int cid, uint32_t wid, uint64_t* out_tags);
extern CGError SLSCopyWindowProperty(unsigned int cid, uint32_t wid, CFStringRef property, CFTypeRef *value);

extern CGError SLSSetWindowLevel(unsigned int cid, uint32_t wid, int level);
extern CGError SLSGetWindowLevel(unsigned int cid, uint32_t wid, int *level);
extern CGError SLSSetWindowSubLevel(unsigned int cid, uint32_t wid, int level);
extern int SLSGetWindowSubLevel(unsigned int cid, uint32_t wid);
extern CGError SLSOrderWindow(unsigned int cid, uint32_t wid, int mode, uint32_t rel_wid);
extern CFTypeRef SLSWindowQueryWindows(unsigned int cid, CFArrayRef windows, int count);
extern CFTypeRef SLSWindowQueryResultCopyWindows(CFTypeRef window_query);
extern int SLSWindowIteratorGetCount(CFTypeRef iterator);
extern bool SLSWindowIteratorAdvance(CFTypeRef iterator);
extern uint32_t SLSWindowIteratorGetParentID(CFTypeRef iterator);
extern uint32_t SLSWindowIteratorGetWindowID(CFTypeRef iterator);
extern uint64_t SLSWindowIteratorGetTags(CFTypeRef iterator);
extern uint64_t SLSWindowIteratorGetAttributes(CFTypeRef iterator);

extern int SLSWindowIteratorGetLevel(CFTypeRef iterator);
extern CFArrayRef SLSCopyWindowsWithOptionsAndTags(unsigned int cid, uint32_t owner, CFArrayRef spaces, uint32_t options, uint64_t *set_tags, uint64_t *clear_tags);
extern CFArrayRef SLSCopyManagedDisplaySpaces(unsigned int cid);
extern CGError SLSGetConnectionIDForPSN(unsigned int cid, ProcessSerialNumber *psn, int *psn_cid);

extern ProcessSerialNumber _LSASNToUInt64(CFTypeRef asn);

extern CGError SLSSetWindowTags(unsigned int cid, uint32_t wid, uint32_t tags[2], int tag_size);
extern CGError SLSClearWindowTags(unsigned int cid, uint32_t wid, uint64_t *tags, int tag_size);
extern CGError SLSNewConnection(unsigned int zero, unsigned int *cid);

extern CGError SLSSetOtherUniversalConnection(unsigned int cid, unsigned int otherConnection);
extern CGError SLSSetUniversalOwner(unsigned int cid);
extern CGError SLSReleaseConnection(unsigned int cid);

extern CGError SLSSetWindowAlpha(unsigned int cid, uint32_t wid, float alpha);

extern uint64_t SLSSpaceCreate(unsigned int cid, int one, CFDictionaryRef options);
extern CGError SLSSpaceSetAbsoluteLevel(unsigned int cid, uint64_t sid, int level);
extern CGError SLSShowSpaces(unsigned int cid, CFArrayRef space_list);

extern CGError SLSSpaceAddWindowsAndRemoveFromSpaces(unsigned int cid, uint64_t sid, CFArrayRef array, int selector);
extern void SLSRemoveWindowsFromSpaces(unsigned int cid, CFArrayRef window_list, CFArrayRef space_list);

extern CFArrayRef SLSCopySpacesForWindows(unsigned int cid, int selector, CFArrayRef window_list);

extern void SLSMoveWindowsToManagedSpace(unsigned int cid, CFArrayRef window_list, uint64_t sid);

extern CFArrayRef SLSHWCaptureWindowList(unsigned int cid, uint32_t *window_list, int window_count, uint32_t options);

typedef void (*SLSNotifyProcPtr)(uint32_t type, void *data, unsigned int dataLength, void *userData);

extern CGError SLSRegisterNotifyProc(SLSNotifyProcPtr proc, uint32_t type, void *userData);
