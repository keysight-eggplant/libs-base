########## Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ##########
# Committed by: Adam Fox
# Commit ID: a312acb8373b24c50854978fa4c2334d2565e870
# Date: 2020-01-02 18:37:58 -0700
--------------------
# Committed by: Adam Fox
# Commit ID: a98b1574f39762a84050a7f0968d94a5eb62604d
# Date: 2020-01-02 18:24:59 -0700
--------------------
# Committed by: Paul Landers
# Commit ID: e7218077411312685abfcfc5b4b5a9e7b6e5a9cf
# Date: 2019-03-04 10:32:36 -0700
--------------------
# Committed by: Paul Landers
# Commit ID: de3fba53b31854882730838f6517fc65bf322835
# Date: 2016-10-12 16:22:07 +0000
########## End of Keysight Technologies Notice ##########
#include <stdio.h>
#include <stdlib.h>
#include <ffi.h>


typedef struct cls_struct_combined {
  float a;
  float b;
  float c;
  float d;

#ifndef __MINGW64__
  // Testplant: Work around 64bit libffi bug passing 16byte structs by value.
  // Note that this workaround was removed for Windows when we moved from
  // clang 3 to clang 7, so this can probably be removed for Linux as well
  // when we get those toolchains up to 7.
  float e;
#endif
} cls_struct_combined;

void cls_struct_combined_fn(struct cls_struct_combined arg)
{
/*
  printf("GOT %g %g %g %g,  EXPECTED 4 5 1 8\n",
	 arg.a, arg.b,
	 arg.c, arg.d);
  fflush(stdout);
*/
  if (arg.a != 4 || arg.b != 5 || arg.c != 1 || arg.d != 8) abort();
}

static void
cls_struct_combined_gn(ffi_cif* cif, void* resp, void** args, void* userdata)
{
  struct cls_struct_combined a0;

  a0 = *(struct cls_struct_combined*)(args[0]);

  cls_struct_combined_fn(a0);
}


int main (void)
{
  ffi_cif cif;
  void *code;
  ffi_closure *pcl = ffi_closure_alloc(sizeof(ffi_closure), &code);
  ffi_type* cls_struct_fields0[6];
  ffi_type cls_struct_type0;
  ffi_type* dbl_arg_types[6];
  struct cls_struct_combined g_dbl = {4.0, 5.0, 1.0, 8.0, 6.0};

  cls_struct_type0.size = 0;
  cls_struct_type0.alignment = 0;
  cls_struct_type0.type = FFI_TYPE_STRUCT;
  cls_struct_type0.elements = cls_struct_fields0;

  cls_struct_fields0[0] = &ffi_type_float;
  cls_struct_fields0[1] = &ffi_type_float;
  cls_struct_fields0[2] = &ffi_type_float;
  cls_struct_fields0[3] = &ffi_type_float;
  cls_struct_fields0[4] = &ffi_type_float;
  cls_struct_fields0[5] = NULL;

  dbl_arg_types[0] = &cls_struct_type0;
  dbl_arg_types[1] = NULL;

cls_struct_combined_fn(g_dbl);

  if (ffi_prep_cif(&cif, FFI_DEFAULT_ABI, 1, &ffi_type_void, dbl_arg_types)
    != FFI_OK) abort();

  if (ffi_prep_closure_loc(pcl, &cif, cls_struct_combined_gn, NULL, code)
    != FFI_OK) abort();

  ((void(*)(cls_struct_combined)) (code))(g_dbl);
  exit(0);
}
