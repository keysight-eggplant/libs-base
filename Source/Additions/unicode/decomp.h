// ========== Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ========== 
// Committed by: Marcian Lytwyn 
// Commit ID: dba962b1310647a291b6583d24a5cafa3a6c49c5 
// Date: 2020-05-18 12:06:59 -0400 
// ========== End of Keysight Technologies Notice ========== 
/* decomposition table */
/*
  Copyright (C) 2005 Free Software Foundation

  Copying and distribution of this file, with or without modification,
  are permitted in any medium without royalty provided the copyright
  notice and this notice are preserved.
*/


struct _dec_ {unichar code; unichar decomp[5];};

static struct _dec_ uni_dec_table[]=
{
{0x00C0, {0x0041, 0x0300, 0}},
{0x00C1, {0x0041, 0x0301, 0}},
{0x00C2, {0x0041, 0x0302, 0}},
{0x00C3, {0x0041, 0x0303, 0}},
{0x00C4, {0x0041, 0x0308, 0}},
{0x00C5, {0x0041, 0x030A, 0}},
{0x00C7, {0x0043, 0x0327, 0}},
{0x00C8, {0x0045, 0x0300, 0}},
{0x00C9, {0x0045, 0x0301, 0}},
{0x00CA, {0x0045, 0x0302, 0}},
{0x00CB, {0x0045, 0x0308, 0}},
{0x00CC, {0x0049, 0x0300, 0}},
{0x00CD, {0x0049, 0x0301, 0}},
{0x00CE, {0x0049, 0x0302, 0}},
{0x00CF, {0x0049, 0x0308, 0}},
{0x00D1, {0x004E, 0x0303, 0}},
{0x00D2, {0x004F, 0x0300, 0}},
{0x00D3, {0x004F, 0x0301, 0}},
{0x00D4, {0x004F, 0x0302, 0}},
{0x00D5, {0x004F, 0x0303, 0}},
{0x00D6, {0x004F, 0x0308, 0}},
{0x00D9, {0x0055, 0x0300, 0}},
{0x00DA, {0x0055, 0x0301, 0}},
{0x00DB, {0x0055, 0x0302, 0}},
{0x00DC, {0x0055, 0x0308, 0}},
{0x00DD, {0x0059, 0x0301, 0}},
{0x00E0, {0x0061, 0x0300, 0}},
{0x00E1, {0x0061, 0x0301, 0}},
{0x00E2, {0x0061, 0x0302, 0}},
{0x00E3, {0x0061, 0x0303, 0}},
{0x00E4, {0x0061, 0x0308, 0}},
{0x00E5, {0x0061, 0x030A, 0}},
{0x00E7, {0x0063, 0x0327, 0}},
{0x00E8, {0x0065, 0x0300, 0}},
{0x00E9, {0x0065, 0x0301, 0}},
{0x00EA, {0x0065, 0x0302, 0}},
{0x00EB, {0x0065, 0x0308, 0}},
{0x00EC, {0x0069, 0x0300, 0}},
{0x00ED, {0x0069, 0x0301, 0}},
{0x00EE, {0x0069, 0x0302, 0}},
{0x00EF, {0x0069, 0x0308, 0}},
{0x00F1, {0x006E, 0x0303, 0}},
{0x00F2, {0x006F, 0x0300, 0}},
{0x00F3, {0x006F, 0x0301, 0}},
{0x00F4, {0x006F, 0x0302, 0}},
{0x00F5, {0x006F, 0x0303, 0}},
{0x00F6, {0x006F, 0x0308, 0}},
{0x00F9, {0x0075, 0x0300, 0}},
{0x00FA, {0x0075, 0x0301, 0}},
{0x00FB, {0x0075, 0x0302, 0}},
{0x00FC, {0x0075, 0x0308, 0}},
{0x00FD, {0x0079, 0x0301, 0}},
{0x00FF, {0x0079, 0x0308, 0}},
{0x0100, {0x0041, 0x0304, 0}},
{0x0101, {0x0061, 0x0304, 0}},
{0x0102, {0x0041, 0x0306, 0}},
{0x0103, {0x0061, 0x0306, 0}},
{0x0104, {0x0041, 0x0328, 0}},
{0x0105, {0x0061, 0x0328, 0}},
{0x0106, {0x0043, 0x0301, 0}},
{0x0107, {0x0063, 0x0301, 0}},
{0x0108, {0x0043, 0x0302, 0}},
{0x0109, {0x0063, 0x0302, 0}},
{0x010A, {0x0043, 0x0307, 0}},
{0x010B, {0x0063, 0x0307, 0}},
{0x010C, {0x0043, 0x030C, 0}},
{0x010D, {0x0063, 0x030C, 0}},
{0x010E, {0x0044, 0x030C, 0}},
{0x010F, {0x0064, 0x030C, 0}},
{0x0112, {0x0045, 0x0304, 0}},
{0x0113, {0x0065, 0x0304, 0}},
{0x0114, {0x0045, 0x0306, 0}},
{0x0115, {0x0065, 0x0306, 0}},
{0x0116, {0x0045, 0x0307, 0}},
{0x0117, {0x0065, 0x0307, 0}},
{0x0118, {0x0045, 0x0328, 0}},
{0x0119, {0x0065, 0x0328, 0}},
{0x011A, {0x0045, 0x030C, 0}},
{0x011B, {0x0065, 0x030C, 0}},
{0x011C, {0x0047, 0x0302, 0}},
{0x011D, {0x0067, 0x0302, 0}},
{0x011E, {0x0047, 0x0306, 0}},
{0x011F, {0x0067, 0x0306, 0}},
{0x0120, {0x0047, 0x0307, 0}},
{0x0121, {0x0067, 0x0307, 0}},
{0x0122, {0x0047, 0x0327, 0}},
{0x0123, {0x0067, 0x0327, 0}},
{0x0124, {0x0048, 0x0302, 0}},
{0x0125, {0x0068, 0x0302, 0}},
{0x0128, {0x0049, 0x0303, 0}},
{0x0129, {0x0069, 0x0303, 0}},
{0x012A, {0x0049, 0x0304, 0}},
{0x012B, {0x0069, 0x0304, 0}},
{0x012C, {0x0049, 0x0306, 0}},
{0x012D, {0x0069, 0x0306, 0}},
{0x012E, {0x0049, 0x0328, 0}},
{0x012F, {0x0069, 0x0328, 0}},
{0x0130, {0x0049, 0x0307, 0}},
{0x0134, {0x004A, 0x0302, 0}},
{0x0135, {0x006A, 0x0302, 0}},
{0x0136, {0x004B, 0x0327, 0}},
{0x0137, {0x006B, 0x0327, 0}},
{0x0139, {0x004C, 0x0301, 0}},
{0x013A, {0x006C, 0x0301, 0}},
{0x013B, {0x004C, 0x0327, 0}},
{0x013C, {0x006C, 0x0327, 0}},
{0x013D, {0x004C, 0x030C, 0}},
{0x013E, {0x006C, 0x030C, 0}},
{0x0143, {0x004E, 0x0301, 0}},
{0x0144, {0x006E, 0x0301, 0}},
{0x0145, {0x004E, 0x0327, 0}},
{0x0146, {0x006E, 0x0327, 0}},
{0x0147, {0x004E, 0x030C, 0}},
{0x0148, {0x006E, 0x030C, 0}},
{0x014C, {0x004F, 0x0304, 0}},
{0x014D, {0x006F, 0x0304, 0}},
{0x014E, {0x004F, 0x0306, 0}},
{0x014F, {0x006F, 0x0306, 0}},
{0x0150, {0x004F, 0x030B, 0}},
{0x0151, {0x006F, 0x030B, 0}},
{0x0154, {0x0052, 0x0301, 0}},
{0x0155, {0x0072, 0x0301, 0}},
{0x0156, {0x0052, 0x0327, 0}},
{0x0157, {0x0072, 0x0327, 0}},
{0x0158, {0x0052, 0x030C, 0}},
{0x0159, {0x0072, 0x030C, 0}},
{0x015A, {0x0053, 0x0301, 0}},
{0x015B, {0x0073, 0x0301, 0}},
{0x015C, {0x0053, 0x0302, 0}},
{0x015D, {0x0073, 0x0302, 0}},
{0x015E, {0x0053, 0x0327, 0}},
{0x015F, {0x0073, 0x0327, 0}},
{0x0160, {0x0053, 0x030C, 0}},
{0x0161, {0x0073, 0x030C, 0}},
{0x0162, {0x0054, 0x0327, 0}},
{0x0163, {0x0074, 0x0327, 0}},
{0x0164, {0x0054, 0x030C, 0}},
{0x0165, {0x0074, 0x030C, 0}},
{0x0168, {0x0055, 0x0303, 0}},
{0x0169, {0x0075, 0x0303, 0}},
{0x016A, {0x0055, 0x0304, 0}},
{0x016B, {0x0075, 0x0304, 0}},
{0x016C, {0x0055, 0x0306, 0}},
{0x016D, {0x0075, 0x0306, 0}},
{0x016E, {0x0055, 0x030A, 0}},
{0x016F, {0x0075, 0x030A, 0}},
{0x0170, {0x0055, 0x030B, 0}},
{0x0171, {0x0075, 0x030B, 0}},
{0x0172, {0x0055, 0x0328, 0}},
{0x0173, {0x0075, 0x0328, 0}},
{0x0174, {0x0057, 0x0302, 0}},
{0x0175, {0x0077, 0x0302, 0}},
{0x0176, {0x0059, 0x0302, 0}},
{0x0177, {0x0079, 0x0302, 0}},
{0x0178, {0x0059, 0x0308, 0}},
{0x0179, {0x005A, 0x0301, 0}},
{0x017A, {0x007A, 0x0301, 0}},
{0x017B, {0x005A, 0x0307, 0}},
{0x017C, {0x007A, 0x0307, 0}},
{0x017D, {0x005A, 0x030C, 0}},
{0x017E, {0x007A, 0x030C, 0}},
{0x01A0, {0x004F, 0x031B, 0}},
{0x01A1, {0x006F, 0x031B, 0}},
{0x01AF, {0x0055, 0x031B, 0}},
{0x01B0, {0x0075, 0x031B, 0}},
{0x01CD, {0x0041, 0x030C, 0}},
{0x01CE, {0x0061, 0x030C, 0}},
{0x01CF, {0x0049, 0x030C, 0}},
{0x01D0, {0x0069, 0x030C, 0}},
{0x01D1, {0x004F, 0x030C, 0}},
{0x01D2, {0x006F, 0x030C, 0}},
{0x01D3, {0x0055, 0x030C, 0}},
{0x01D4, {0x0075, 0x030C, 0}},
{0x01D5, {0x00DC, 0x0304, 0}},
{0x01D6, {0x00FC, 0x0304, 0}},
{0x01D7, {0x00DC, 0x0301, 0}},
{0x01D8, {0x00FC, 0x0301, 0}},
{0x01D9, {0x00DC, 0x030C, 0}},
{0x01DA, {0x00FC, 0x030C, 0}},
{0x01DB, {0x00DC, 0x0300, 0}},
{0x01DC, {0x00FC, 0x0300, 0}},
{0x01DE, {0x00C4, 0x0304, 0}},
{0x01DF, {0x00E4, 0x0304, 0}},
{0x01E0, {0x0041, 0x0307, 0x0304, 0}},
{0x01E1, {0x0061, 0x0307, 0x0304, 0}},
{0x01E2, {0x00C6, 0x0304, 0}},
{0x01E3, {0x00E6, 0x0304, 0}},
{0x01E6, {0x0047, 0x030C, 0}},
{0x01E7, {0x0067, 0x030C, 0}},
{0x01E8, {0x004B, 0x030C, 0}},
{0x01E9, {0x006B, 0x030C, 0}},
{0x01EA, {0x004F, 0x0328, 0}},
{0x01EB, {0x006F, 0x0328, 0}},
{0x01EC, {0x01EA, 0x0304, 0}},
{0x01ED, {0x01EB, 0x0304, 0}},
{0x01EE, {0x01B7, 0x030C, 0}},
{0x01EF, {0x0292, 0x030C, 0}},
{0x01F0, {0x006A, 0x030C, 0}},
{0x01F4, {0x0047, 0x0301, 0}},
{0x01F5, {0x0067, 0x0301, 0}},
{0x01FA, {0x00C5, 0x0301, 0}},
{0x01FB, {0x00E5, 0x0301, 0}},
{0x01FC, {0x00C6, 0x0301, 0}},
{0x01FD, {0x00E6, 0x0301, 0}},
{0x01FE, {0x00D8, 0x0301, 0}},
{0x01FF, {0x00F8, 0x0301, 0}},
{0x0200, {0x0041, 0x030F, 0}},
{0x0201, {0x0061, 0x030F, 0}},
{0x0202, {0x0041, 0x0311, 0}},
{0x0203, {0x0061, 0x0311, 0}},
{0x0204, {0x0045, 0x030F, 0}},
{0x0205, {0x0065, 0x030F, 0}},
{0x0206, {0x0045, 0x0311, 0}},
{0x0207, {0x0065, 0x0311, 0}},
{0x0208, {0x0049, 0x030F, 0}},
{0x0209, {0x0069, 0x030F, 0}},
{0x020A, {0x0049, 0x0311, 0}},
{0x020B, {0x0069, 0x0311, 0}},
{0x020C, {0x004F, 0x030F, 0}},
{0x020D, {0x006F, 0x030F, 0}},
{0x020E, {0x004F, 0x0311, 0}},
{0x020F, {0x006F, 0x0311, 0}},
{0x0210, {0x0052, 0x030F, 0}},
{0x0211, {0x0072, 0x030F, 0}},
{0x0212, {0x0052, 0x0311, 0}},
{0x0213, {0x0072, 0x0311, 0}},
{0x0214, {0x0055, 0x030F, 0}},
{0x0215, {0x0075, 0x030F, 0}},
{0x0216, {0x0055, 0x0311, 0}},
{0x0217, {0x0075, 0x0311, 0}},
{0x0310, {0x0306, 0x0307, 0}},
{0x0340, {0x0300, 0}},
{0x0341, {0x0301, 0}},
{0x0343, {0x0313, 0}},
{0x0344, {0x0308, 0x030D, 0}},
{0x0374, {0x02B9, 0}},
{0x037E, {0x003B, 0}},
{0x0385, {0x00A8, 0x030D, 0}},
{0x0386, {0x0391, 0x030D, 0}},
{0x0387, {0x00B7, 0}},
{0x0388, {0x0395, 0x030D, 0}},
{0x0389, {0x0397, 0x030D, 0}},
{0x038A, {0x0399, 0x030D, 0}},
{0x038C, {0x039F, 0x030D, 0}},
{0x038E, {0x03A5, 0x030D, 0}},
{0x038F, {0x03A9, 0x030D, 0}},
{0x0390, {0x03B9, 0x0344, 0}},
{0x03AA, {0x0399, 0x0308, 0}},
{0x03AB, {0x03A5, 0x0308, 0}},
{0x03AC, {0x03B1, 0x030D, 0}},
{0x03AD, {0x03B5, 0x030D, 0}},
{0x03AE, {0x03B7, 0x030D, 0}},
{0x03AF, {0x03B9, 0x030D, 0}},
{0x03B0, {0x03C5, 0x0344, 0}},
{0x03CA, {0x03B9, 0x0308, 0}},
{0x03CB, {0x03C5, 0x0308, 0}},
{0x03CC, {0x03BF, 0x030D, 0}},
{0x03CD, {0x03C5, 0x030D, 0}},
{0x03CE, {0x03C9, 0x030D, 0}},
{0x03D3, {0x03D2, 0x030D, 0}},
{0x03D4, {0x03D2, 0x0308, 0}},
{0x0401, {0x0415, 0x0308, 0}},
{0x0403, {0x0413, 0x0301, 0}},
{0x0407, {0x0406, 0x0308, 0}},
{0x040C, {0x041A, 0x0301, 0}},
{0x040E, {0x0423, 0x0306, 0}},
{0x0419, {0x0418, 0x0306, 0}},
{0x0439, {0x0438, 0x0306, 0}},
{0x0451, {0x0435, 0x0308, 0}},
{0x0453, {0x0433, 0x0301, 0}},
{0x0457, {0x0456, 0x0308, 0}},
{0x045C, {0x043A, 0x0301, 0}},
{0x045E, {0x0443, 0x0306, 0}},
{0x0476, {0x0474, 0x030F, 0}},
{0x0477, {0x0475, 0x030F, 0}},
{0x04C1, {0x0416, 0x0306, 0}},
{0x04C2, {0x0436, 0x0306, 0}},
{0x04D0, {0x0410, 0x0306, 0}},
{0x04D1, {0x0430, 0x0306, 0}},
{0x04D2, {0x0410, 0x0308, 0}},
{0x04D3, {0x0430, 0x0308, 0}},
{0x04D4, {0x00C6, 0}},
{0x04D5, {0x00E6, 0}},
{0x04D6, {0x0415, 0x0306, 0}},
{0x04D7, {0x0435, 0x0306, 0}},
{0x04D8, {0x018F, 0}},
{0x04D9, {0x0259, 0}},
{0x04DA, {0x018F, 0x0308, 0}},
{0x04DB, {0x0259, 0x0308, 0}},
{0x04DC, {0x0416, 0x0308, 0}},
{0x04DD, {0x0436, 0x0308, 0}},
{0x04DE, {0x0417, 0x0308, 0}},
{0x04DF, {0x0437, 0x0308, 0}},
{0x04E0, {0x01B7, 0}},
{0x04E1, {0x0292, 0}},
{0x04E2, {0x0418, 0x0304, 0}},
{0x04E3, {0x0438, 0x0304, 0}},
{0x04E4, {0x0418, 0x0308, 0}},
{0x04E5, {0x0438, 0x0308, 0}},
{0x04E6, {0x041E, 0x0308, 0}},
{0x04E7, {0x043E, 0x0308, 0}},
{0x04E8, {0x019F, 0}},
{0x04E9, {0x0275, 0}},
{0x04EA, {0x019F, 0x0308, 0}},
{0x04EB, {0x0275, 0x0308, 0}},
{0x04EE, {0x0423, 0x0304, 0}},
{0x04EF, {0x0443, 0x0304, 0}},
{0x04F0, {0x0423, 0x0308, 0}},
{0x04F1, {0x0443, 0x0308, 0}},
{0x04F2, {0x0423, 0x030B, 0}},
{0x04F3, {0x0443, 0x030B, 0}},
{0x04F4, {0x0427, 0x0308, 0}},
{0x04F5, {0x0447, 0x0308, 0}},
{0x04F8, {0x042B, 0x0308, 0}},
{0x04F9, {0x044B, 0x0308, 0}},
{0x0929, {0x0928, 0x093C, 0}},
{0x0931, {0x0930, 0x093C, 0}},
{0x0934, {0x0933, 0x093C, 0}},
{0x0958, {0x0915, 0x093C, 0}},
{0x0959, {0x0916, 0x093C, 0}},
{0x095A, {0x0917, 0x093C, 0}},
{0x095B, {0x091C, 0x093C, 0}},
{0x095C, {0x0921, 0x093C, 0}},
{0x095D, {0x0922, 0x093C, 0}},
{0x095E, {0x092B, 0x093C, 0}},
{0x095F, {0x092F, 0x093C, 0}},
{0x09B0, {0x09AC, 0x09BC, 0}},
{0x09CB, {0x09C7, 0x09BE, 0}},
{0x09CC, {0x09C7, 0x09D7, 0}},
{0x09DC, {0x09A1, 0x09BC, 0}},
{0x09DD, {0x09A2, 0x09BC, 0}},
{0x09DF, {0x09AF, 0x09BC, 0}},
{0x0A59, {0x0A16, 0x0A3C, 0}},
{0x0A5A, {0x0A17, 0x0A3C, 0}},
{0x0A5B, {0x0A1C, 0x0A3C, 0}},
{0x0A5C, {0x0A21, 0x0A3C, 0}},
{0x0A5E, {0x0A2B, 0x0A3C, 0}},
{0x0B48, {0x0B47, 0x0B56, 0}},
{0x0B4B, {0x0B47, 0x0B3E, 0}},
{0x0B4C, {0x0B47, 0x0B57, 0}},
{0x0B5C, {0x0B21, 0x0B3C, 0}},
{0x0B5D, {0x0B22, 0x0B3C, 0}},
{0x0B5F, {0x0B2F, 0x0B3C, 0}},
{0x0B94, {0x0B92, 0x0BD7, 0}},
{0x0BCA, {0x0BC6, 0x0BBE, 0}},
{0x0BCB, {0x0BC7, 0x0BBE, 0}},
{0x0BCC, {0x0BC6, 0x0BD7, 0}},
{0x0C48, {0x0C46, 0x0C56, 0}},
{0x0CC0, {0x0CBF, 0x0CD5, 0}},
{0x0CC7, {0x0CC6, 0x0CD5, 0}},
{0x0CC8, {0x0CC6, 0x0CD6, 0}},
{0x0CCA, {0x0CC6, 0x0CC2, 0}},
{0x0CCB, {0x0CC6, 0x0CC2, 0x0CD5, 0}},
{0x0D4A, {0x0D46, 0x0D3E, 0}},
{0x0D4B, {0x0D47, 0x0D3E, 0}},
{0x0D4C, {0x0D46, 0x0D57, 0}},
{0x0E33, {0x0E4D, 0x0E32, 0}},
{0x0EB3, {0x0ECD, 0x0EB2, 0}},
{0x0F43, {0x0F42, 0x0FB7, 0}},
{0x0F4D, {0x0F4C, 0x0FB7, 0}},
{0x0F52, {0x0F51, 0x0FB7, 0}},
{0x0F57, {0x0F56, 0x0FB7, 0}},
{0x0F5C, {0x0F5B, 0x0FB7, 0}},
{0x0F69, {0x0F40, 0x0FB5, 0}},
{0x0F73, {0x0F71, 0x0F72, 0}},
{0x0F75, {0x0F74, 0x0F71, 0}},
{0x0F76, {0x0FB2, 0x0F80, 0}},
{0x0F77, {0x0F76, 0x0F71, 0}},
{0x0F78, {0x0FB3, 0x0F80, 0}},
{0x0F79, {0x0F78, 0x0F71, 0}},
{0x0F81, {0x0F80, 0x0F71, 0}},
{0x0F93, {0x0F92, 0x0FB7, 0}},
{0x0F9D, {0x0F9C, 0x0FB7, 0}},
{0x0FA2, {0x0FA1, 0x0FB7, 0}},
{0x0FA7, {0x0FA6, 0x0FB7, 0}},
{0x0FAC, {0x0FAB, 0x0FB7, 0}},
{0x0FB9, {0x0F90, 0x0FB5, 0}},
{0x1E00, {0x0041, 0x0325, 0}},
{0x1E01, {0x0061, 0x0325, 0}},
{0x1E02, {0x0042, 0x0307, 0}},
{0x1E03, {0x0062, 0x0307, 0}},
{0x1E04, {0x0042, 0x0323, 0}},
{0x1E05, {0x0062, 0x0323, 0}},
{0x1E06, {0x0042, 0x0331, 0}},
{0x1E07, {0x0062, 0x0331, 0}},
{0x1E08, {0x00C7, 0x0301, 0}},
{0x1E09, {0x00E7, 0x0301, 0}},
{0x1E0A, {0x0044, 0x0307, 0}},
{0x1E0B, {0x0064, 0x0307, 0}},
{0x1E0C, {0x0044, 0x0323, 0}},
{0x1E0D, {0x0064, 0x0323, 0}},
{0x1E0E, {0x0044, 0x0331, 0}},
{0x1E0F, {0x0064, 0x0331, 0}},
{0x1E10, {0x0044, 0x0327, 0}},
{0x1E11, {0x0064, 0x0327, 0}},
{0x1E12, {0x0044, 0x032D, 0}},
{0x1E13, {0x0064, 0x032D, 0}},
{0x1E14, {0x0112, 0x0300, 0}},
{0x1E15, {0x0113, 0x0300, 0}},
{0x1E16, {0x0112, 0x0301, 0}},
{0x1E17, {0x0113, 0x0301, 0}},
{0x1E18, {0x0045, 0x032D, 0}},
{0x1E19, {0x0065, 0x032D, 0}},
{0x1E1A, {0x0045, 0x0330, 0}},
{0x1E1B, {0x0065, 0x0330, 0}},
{0x1E1C, {0x0114, 0x0327, 0}},
{0x1E1D, {0x0115, 0x0327, 0}},
{0x1E1E, {0x0046, 0x0307, 0}},
{0x1E1F, {0x0066, 0x0307, 0}},
{0x1E20, {0x0047, 0x0304, 0}},
{0x1E21, {0x0067, 0x0304, 0}},
{0x1E22, {0x0048, 0x0307, 0}},
{0x1E23, {0x0068, 0x0307, 0}},
{0x1E24, {0x0048, 0x0323, 0}},
{0x1E25, {0x0068, 0x0323, 0}},
{0x1E26, {0x0048, 0x0308, 0}},
{0x1E27, {0x0068, 0x0308, 0}},
{0x1E28, {0x0048, 0x0327, 0}},
{0x1E29, {0x0068, 0x0327, 0}},
{0x1E2A, {0x0048, 0x032E, 0}},
{0x1E2B, {0x0068, 0x032E, 0}},
{0x1E2C, {0x0049, 0x0330, 0}},
{0x1E2D, {0x0069, 0x0330, 0}},
{0x1E2E, {0x00CF, 0x0301, 0}},
{0x1E2F, {0x00EF, 0x0301, 0}},
{0x1E30, {0x004B, 0x0301, 0}},
{0x1E31, {0x006B, 0x0301, 0}},
{0x1E32, {0x004B, 0x0323, 0}},
{0x1E33, {0x006B, 0x0323, 0}},
{0x1E34, {0x004B, 0x0331, 0}},
{0x1E35, {0x006B, 0x0331, 0}},
{0x1E36, {0x004C, 0x0323, 0}},
{0x1E37, {0x006C, 0x0323, 0}},
{0x1E38, {0x1E36, 0x0304, 0}},
{0x1E39, {0x1E37, 0x0304, 0}},
{0x1E3A, {0x004C, 0x0331, 0}},
{0x1E3B, {0x006C, 0x0331, 0}},
{0x1E3C, {0x004C, 0x032D, 0}},
{0x1E3D, {0x006C, 0x032D, 0}},
{0x1E3E, {0x004D, 0x0301, 0}},
{0x1E3F, {0x006D, 0x0301, 0}},
{0x1E40, {0x004D, 0x0307, 0}},
{0x1E41, {0x006D, 0x0307, 0}},
{0x1E42, {0x004D, 0x0323, 0}},
{0x1E43, {0x006D, 0x0323, 0}},
{0x1E44, {0x004E, 0x0307, 0}},
{0x1E45, {0x006E, 0x0307, 0}},
{0x1E46, {0x004E, 0x0323, 0}},
{0x1E47, {0x006E, 0x0323, 0}},
{0x1E48, {0x004E, 0x0331, 0}},
{0x1E49, {0x006E, 0x0331, 0}},
{0x1E4A, {0x004E, 0x032D, 0}},
{0x1E4B, {0x006E, 0x032D, 0}},
{0x1E4C, {0x00D5, 0x0301, 0}},
{0x1E4D, {0x00F5, 0x0301, 0}},
{0x1E4E, {0x00D5, 0x0308, 0}},
{0x1E4F, {0x00F5, 0x0308, 0}},
{0x1E50, {0x014C, 0x0300, 0}},
{0x1E51, {0x014D, 0x0300, 0}},
{0x1E52, {0x014C, 0x0301, 0}},
{0x1E53, {0x014D, 0x0301, 0}},
{0x1E54, {0x0050, 0x0301, 0}},
{0x1E55, {0x0070, 0x0301, 0}},
{0x1E56, {0x0050, 0x0307, 0}},
{0x1E57, {0x0070, 0x0307, 0}},
{0x1E58, {0x0052, 0x0307, 0}},
{0x1E59, {0x0072, 0x0307, 0}},
{0x1E5A, {0x0052, 0x0323, 0}},
{0x1E5B, {0x0072, 0x0323, 0}},
{0x1E5C, {0x1E5A, 0x0304, 0}},
{0x1E5D, {0x1E5B, 0x0304, 0}},
{0x1E5E, {0x0052, 0x0331, 0}},
{0x1E5F, {0x0072, 0x0331, 0}},
{0x1E60, {0x0053, 0x0307, 0}},
{0x1E61, {0x0073, 0x0307, 0}},
{0x1E62, {0x0053, 0x0323, 0}},
{0x1E63, {0x0073, 0x0323, 0}},
{0x1E64, {0x015A, 0x0307, 0}},
{0x1E65, {0x015B, 0x0307, 0}},
{0x1E66, {0x0160, 0x0307, 0}},
{0x1E67, {0x0161, 0x0307, 0}},
{0x1E68, {0x1E62, 0x0307, 0}},
{0x1E69, {0x1E63, 0x0307, 0}},
{0x1E6A, {0x0054, 0x0307, 0}},
{0x1E6B, {0x0074, 0x0307, 0}},
{0x1E6C, {0x0054, 0x0323, 0}},
{0x1E6D, {0x0074, 0x0323, 0}},
{0x1E6E, {0x0054, 0x0331, 0}},
{0x1E6F, {0x0074, 0x0331, 0}},
{0x1E70, {0x0054, 0x032D, 0}},
{0x1E71, {0x0074, 0x032D, 0}},
{0x1E72, {0x0055, 0x0324, 0}},
{0x1E73, {0x0075, 0x0324, 0}},
{0x1E74, {0x0055, 0x0330, 0}},
{0x1E75, {0x0075, 0x0330, 0}},
{0x1E76, {0x0055, 0x032D, 0}},
{0x1E77, {0x0075, 0x032D, 0}},
{0x1E78, {0x0168, 0x0301, 0}},
{0x1E79, {0x0169, 0x0301, 0}},
{0x1E7A, {0x016A, 0x0308, 0}},
{0x1E7B, {0x016B, 0x0308, 0}},
{0x1E7C, {0x0056, 0x0303, 0}},
{0x1E7D, {0x0076, 0x0303, 0}},
{0x1E7E, {0x0056, 0x0323, 0}},
{0x1E7F, {0x0076, 0x0323, 0}},
{0x1E80, {0x0057, 0x0300, 0}},
{0x1E81, {0x0077, 0x0300, 0}},
{0x1E82, {0x0057, 0x0301, 0}},
{0x1E83, {0x0077, 0x0301, 0}},
{0x1E84, {0x0057, 0x0308, 0}},
{0x1E85, {0x0077, 0x0308, 0}},
{0x1E86, {0x0057, 0x0307, 0}},
{0x1E87, {0x0077, 0x0307, 0}},
{0x1E88, {0x0057, 0x0323, 0}},
{0x1E89, {0x0077, 0x0323, 0}},
{0x1E8A, {0x0058, 0x0307, 0}},
{0x1E8B, {0x0078, 0x0307, 0}},
{0x1E8C, {0x0058, 0x0308, 0}},
{0x1E8D, {0x0078, 0x0308, 0}},
{0x1E8E, {0x0059, 0x0307, 0}},
{0x1E8F, {0x0079, 0x0307, 0}},
{0x1E90, {0x005A, 0x0302, 0}},
{0x1E91, {0x007A, 0x0302, 0}},
{0x1E92, {0x005A, 0x0323, 0}},
{0x1E93, {0x007A, 0x0323, 0}},
{0x1E94, {0x005A, 0x0331, 0}},
{0x1E95, {0x007A, 0x0331, 0}},
{0x1E96, {0x0068, 0x0331, 0}},
{0x1E97, {0x0074, 0x0308, 0}},
{0x1E98, {0x0077, 0x030A, 0}},
{0x1E99, {0x0079, 0x030A, 0}},
{0x1E9B, {0x017F, 0x0307, 0}},
{0x1EA0, {0x0041, 0x0323, 0}},
{0x1EA1, {0x0061, 0x0323, 0}},
{0x1EA2, {0x0041, 0x0309, 0}},
{0x1EA3, {0x0061, 0x0309, 0}},
{0x1EA4, {0x00C2, 0x0301, 0}},
{0x1EA5, {0x00E2, 0x0301, 0}},
{0x1EA6, {0x00C2, 0x0300, 0}},
{0x1EA7, {0x00E2, 0x0300, 0}},
{0x1EA8, {0x00C2, 0x0309, 0}},
{0x1EA9, {0x00E2, 0x0309, 0}},
{0x1EAA, {0x00C2, 0x0303, 0}},
{0x1EAB, {0x00E2, 0x0303, 0}},
{0x1EAC, {0x00C2, 0x0323, 0}},
{0x1EAD, {0x00E2, 0x0323, 0}},
{0x1EAE, {0x0102, 0x0301, 0}},
{0x1EAF, {0x0103, 0x0301, 0}},
{0x1EB0, {0x0102, 0x0300, 0}},
{0x1EB1, {0x0103, 0x0300, 0}},
{0x1EB2, {0x0102, 0x0309, 0}},
{0x1EB3, {0x0103, 0x0309, 0}},
{0x1EB4, {0x0102, 0x0303, 0}},
{0x1EB5, {0x0103, 0x0303, 0}},
{0x1EB6, {0x0102, 0x0323, 0}},
{0x1EB7, {0x0103, 0x0323, 0}},
{0x1EB8, {0x0045, 0x0323, 0}},
{0x1EB9, {0x0065, 0x0323, 0}},
{0x1EBA, {0x0045, 0x0309, 0}},
{0x1EBB, {0x0065, 0x0309, 0}},
{0x1EBC, {0x0045, 0x0303, 0}},
{0x1EBD, {0x0065, 0x0303, 0}},
{0x1EBE, {0x00CA, 0x0301, 0}},
{0x1EBF, {0x00EA, 0x0301, 0}},
{0x1EC0, {0x00CA, 0x0300, 0}},
{0x1EC1, {0x00EA, 0x0300, 0}},
{0x1EC2, {0x00CA, 0x0309, 0}},
{0x1EC3, {0x00EA, 0x0309, 0}},
{0x1EC4, {0x00CA, 0x0303, 0}},
{0x1EC5, {0x00EA, 0x0303, 0}},
{0x1EC6, {0x00CA, 0x0323, 0}},
{0x1EC7, {0x00EA, 0x0323, 0}},
{0x1EC8, {0x0049, 0x0309, 0}},
{0x1EC9, {0x0069, 0x0309, 0}},
{0x1ECA, {0x0049, 0x0323, 0}},
{0x1ECB, {0x0069, 0x0323, 0}},
{0x1ECC, {0x004F, 0x0323, 0}},
{0x1ECD, {0x006F, 0x0323, 0}},
{0x1ECE, {0x004F, 0x0309, 0}},
{0x1ECF, {0x006F, 0x0309, 0}},
{0x1ED0, {0x00D4, 0x0301, 0}},
{0x1ED1, {0x00F4, 0x0301, 0}},
{0x1ED2, {0x00D4, 0x0300, 0}},
{0x1ED3, {0x00F4, 0x0300, 0}},
{0x1ED4, {0x00D4, 0x0309, 0}},
{0x1ED5, {0x00F4, 0x0309, 0}},
{0x1ED6, {0x00D4, 0x0303, 0}},
{0x1ED7, {0x00F4, 0x0303, 0}},
{0x1ED8, {0x00D4, 0x0323, 0}},
{0x1ED9, {0x00F4, 0x0323, 0}},
{0x1EDA, {0x01A0, 0x0301, 0}},
{0x1EDB, {0x01A1, 0x0301, 0}},
{0x1EDC, {0x01A0, 0x0300, 0}},
{0x1EDD, {0x01A1, 0x0300, 0}},
{0x1EDE, {0x01A0, 0x0309, 0}},
{0x1EDF, {0x01A1, 0x0309, 0}},
{0x1EE0, {0x01A0, 0x0303, 0}},
{0x1EE1, {0x01A1, 0x0303, 0}},
{0x1EE2, {0x01A0, 0x0323, 0}},
{0x1EE3, {0x01A1, 0x0323, 0}},
{0x1EE4, {0x0055, 0x0323, 0}},
{0x1EE5, {0x0075, 0x0323, 0}},
{0x1EE6, {0x0055, 0x0309, 0}},
{0x1EE7, {0x0075, 0x0309, 0}},
{0x1EE8, {0x01AF, 0x0301, 0}},
{0x1EE9, {0x01B0, 0x0301, 0}},
{0x1EEA, {0x01AF, 0x0300, 0}},
{0x1EEB, {0x01B0, 0x0300, 0}},
{0x1EEC, {0x01AF, 0x0309, 0}},
{0x1EED, {0x01B0, 0x0309, 0}},
{0x1EEE, {0x01AF, 0x0303, 0}},
{0x1EEF, {0x01B0, 0x0303, 0}},
{0x1EF0, {0x01AF, 0x0323, 0}},
{0x1EF1, {0x01B0, 0x0323, 0}},
{0x1EF2, {0x0059, 0x0300, 0}},
{0x1EF3, {0x0079, 0x0300, 0}},
{0x1EF4, {0x0059, 0x0323, 0}},
{0x1EF5, {0x0079, 0x0323, 0}},
{0x1EF6, {0x0059, 0x0309, 0}},
{0x1EF7, {0x0079, 0x0309, 0}},
{0x1EF8, {0x0059, 0x0303, 0}},
{0x1EF9, {0x0079, 0x0303, 0}},
{0x1F00, {0x03B1, 0x0313, 0}},
{0x1F01, {0x03B1, 0x0314, 0}},
{0x1F02, {0x1F00, 0x0300, 0}},
{0x1F03, {0x1F01, 0x0300, 0}},
{0x1F04, {0x1F00, 0x0301, 0}},
{0x1F05, {0x1F01, 0x0301, 0}},
{0x1F06, {0x1F00, 0x0342, 0}},
{0x1F07, {0x1F01, 0x0342, 0}},
{0x1F08, {0x0391, 0x0313, 0}},
{0x1F09, {0x0391, 0x0314, 0}},
{0x1F0A, {0x1F08, 0x0300, 0}},
{0x1F0B, {0x1F09, 0x0300, 0}},
{0x1F0C, {0x1F08, 0x0301, 0}},
{0x1F0D, {0x1F09, 0x0301, 0}},
{0x1F0E, {0x1F08, 0x0342, 0}},
{0x1F0F, {0x1F09, 0x0342, 0}},
{0x1F10, {0x03B5, 0x0313, 0}},
{0x1F11, {0x03B5, 0x0314, 0}},
{0x1F12, {0x1F10, 0x0300, 0}},
{0x1F13, {0x1F11, 0x0300, 0}},
{0x1F14, {0x1F10, 0x0301, 0}},
{0x1F15, {0x1F11, 0x0301, 0}},
{0x1F18, {0x0395, 0x0313, 0}},
{0x1F19, {0x0395, 0x0314, 0}},
{0x1F1A, {0x1F18, 0x0300, 0}},
{0x1F1B, {0x1F19, 0x0300, 0}},
{0x1F1C, {0x1F18, 0x0301, 0}},
{0x1F1D, {0x1F19, 0x0301, 0}},
{0x1F20, {0x03B7, 0x0313, 0}},
{0x1F21, {0x03B7, 0x0314, 0}},
{0x1F22, {0x1F20, 0x0300, 0}},
{0x1F23, {0x1F21, 0x0300, 0}},
{0x1F24, {0x1F20, 0x0301, 0}},
{0x1F25, {0x1F21, 0x0301, 0}},
{0x1F26, {0x1F20, 0x0342, 0}},
{0x1F27, {0x1F21, 0x0342, 0}},
{0x1F28, {0x0397, 0x0313, 0}},
{0x1F29, {0x0397, 0x0314, 0}},
{0x1F2A, {0x1F28, 0x0300, 0}},
{0x1F2B, {0x1F29, 0x0300, 0}},
{0x1F2C, {0x1F28, 0x0301, 0}},
{0x1F2D, {0x1F29, 0x0301, 0}},
{0x1F2E, {0x1F28, 0x0342, 0}},
{0x1F2F, {0x1F29, 0x0342, 0}},
{0x1F30, {0x03B9, 0x0313, 0}},
{0x1F31, {0x03B9, 0x0314, 0}},
{0x1F32, {0x1F30, 0x0300, 0}},
{0x1F33, {0x1F31, 0x0300, 0}},
{0x1F34, {0x1F30, 0x0301, 0}},
{0x1F35, {0x1F31, 0x0301, 0}},
{0x1F36, {0x1F30, 0x0342, 0}},
{0x1F37, {0x1F31, 0x0342, 0}},
{0x1F38, {0x0399, 0x0313, 0}},
{0x1F39, {0x0399, 0x0314, 0}},
{0x1F3A, {0x1F38, 0x0300, 0}},
{0x1F3B, {0x1F39, 0x0300, 0}},
{0x1F3C, {0x1F38, 0x0301, 0}},
{0x1F3D, {0x1F39, 0x0301, 0}},
{0x1F3E, {0x1F38, 0x0342, 0}},
{0x1F3F, {0x1F39, 0x0342, 0}},
{0x1F40, {0x03BF, 0x0313, 0}},
{0x1F41, {0x03BF, 0x0314, 0}},
{0x1F42, {0x1F40, 0x0300, 0}},
{0x1F43, {0x1F41, 0x0300, 0}},
{0x1F44, {0x1F40, 0x0301, 0}},
{0x1F45, {0x1F41, 0x0301, 0}},
{0x1F48, {0x039F, 0x0313, 0}},
{0x1F49, {0x039F, 0x0314, 0}},
{0x1F4A, {0x1F48, 0x0300, 0}},
{0x1F4B, {0x1F49, 0x0300, 0}},
{0x1F4C, {0x1F48, 0x0301, 0}},
{0x1F4D, {0x1F49, 0x0301, 0}},
{0x1F50, {0x03C5, 0x0313, 0}},
{0x1F51, {0x03C5, 0x0314, 0}},
{0x1F52, {0x1F50, 0x0300, 0}},
{0x1F53, {0x1F51, 0x0300, 0}},
{0x1F54, {0x1F50, 0x0301, 0}},
{0x1F55, {0x1F51, 0x0301, 0}},
{0x1F56, {0x1F50, 0x0342, 0}},
{0x1F57, {0x1F51, 0x0342, 0}},
{0x1F59, {0x03A5, 0x0314, 0}},
{0x1F5B, {0x1F59, 0x0300, 0}},
{0x1F5D, {0x1F59, 0x0301, 0}},
{0x1F5F, {0x1F59, 0x0342, 0}},
{0x1F60, {0x03C9, 0x0313, 0}},
{0x1F61, {0x03C9, 0x0314, 0}},
{0x1F62, {0x1F60, 0x0300, 0}},
{0x1F63, {0x1F61, 0x0300, 0}},
{0x1F64, {0x1F60, 0x0301, 0}},
{0x1F65, {0x1F61, 0x0301, 0}},
{0x1F66, {0x1F60, 0x0342, 0}},
{0x1F67, {0x1F61, 0x0342, 0}},
{0x1F68, {0x03A9, 0x0313, 0}},
{0x1F69, {0x03A9, 0x0314, 0}},
{0x1F6A, {0x1F68, 0x0300, 0}},
{0x1F6B, {0x1F69, 0x0300, 0}},
{0x1F6C, {0x1F68, 0x0301, 0}},
{0x1F6D, {0x1F69, 0x0301, 0}},
{0x1F6E, {0x1F68, 0x0342, 0}},
{0x1F6F, {0x1F69, 0x0342, 0}},
{0x1F70, {0x03B1, 0x0300, 0}},
{0x1F71, {0x03B1, 0x0301, 0}},
{0x1F72, {0x03B5, 0x0300, 0}},
{0x1F73, {0x03B5, 0x0301, 0}},
{0x1F74, {0x03B7, 0x0300, 0}},
{0x1F75, {0x03B7, 0x0301, 0}},
{0x1F76, {0x03B9, 0x0300, 0}},
{0x1F77, {0x03B9, 0x0301, 0}},
{0x1F78, {0x03BF, 0x0300, 0}},
{0x1F79, {0x03BF, 0x0301, 0}},
{0x1F7A, {0x03C5, 0x0300, 0}},
{0x1F7B, {0x03C5, 0x0301, 0}},
{0x1F7C, {0x03C9, 0x0300, 0}},
{0x1F7D, {0x03C9, 0x0301, 0}},
{0x1F80, {0x1F00, 0x0345, 0}},
{0x1F81, {0x1F01, 0x0345, 0}},
{0x1F82, {0x1F02, 0x0345, 0}},
{0x1F83, {0x1F03, 0x0345, 0}},
{0x1F84, {0x1F04, 0x0345, 0}},
{0x1F85, {0x1F05, 0x0345, 0}},
{0x1F86, {0x1F06, 0x0345, 0}},
{0x1F87, {0x1F07, 0x0345, 0}},
{0x1F88, {0x1F08, 0x0345, 0}},
{0x1F89, {0x1F09, 0x0345, 0}},
{0x1F8A, {0x1F0A, 0x0345, 0}},
{0x1F8B, {0x1F0B, 0x0345, 0}},
{0x1F8C, {0x1F0C, 0x0345, 0}},
{0x1F8D, {0x1F0D, 0x0345, 0}},
{0x1F8E, {0x1F0E, 0x0345, 0}},
{0x1F8F, {0x1F0F, 0x0345, 0}},
{0x1F90, {0x1F20, 0x0345, 0}},
{0x1F91, {0x1F21, 0x0345, 0}},
{0x1F92, {0x1F22, 0x0345, 0}},
{0x1F93, {0x1F23, 0x0345, 0}},
{0x1F94, {0x1F24, 0x0345, 0}},
{0x1F95, {0x1F25, 0x0345, 0}},
{0x1F96, {0x1F26, 0x0345, 0}},
{0x1F97, {0x1F27, 0x0345, 0}},
{0x1F98, {0x1F28, 0x0345, 0}},
{0x1F99, {0x1F29, 0x0345, 0}},
{0x1F9A, {0x1F2A, 0x0345, 0}},
{0x1F9B, {0x1F2B, 0x0345, 0}},
{0x1F9C, {0x1F2C, 0x0345, 0}},
{0x1F9D, {0x1F2D, 0x0345, 0}},
{0x1F9E, {0x1F2E, 0x0345, 0}},
{0x1F9F, {0x1F2F, 0x0345, 0}},
{0x1FA0, {0x1F60, 0x0345, 0}},
{0x1FA1, {0x1F61, 0x0345, 0}},
{0x1FA2, {0x1F62, 0x0345, 0}},
{0x1FA3, {0x1F63, 0x0345, 0}},
{0x1FA4, {0x1F64, 0x0345, 0}},
{0x1FA5, {0x1F65, 0x0345, 0}},
{0x1FA6, {0x1F66, 0x0345, 0}},
{0x1FA7, {0x1F67, 0x0345, 0}},
{0x1FA8, {0x1F68, 0x0345, 0}},
{0x1FA9, {0x1F69, 0x0345, 0}},
{0x1FAA, {0x1F6A, 0x0345, 0}},
{0x1FAB, {0x1F6B, 0x0345, 0}},
{0x1FAC, {0x1F6C, 0x0345, 0}},
{0x1FAD, {0x1F6D, 0x0345, 0}},
{0x1FAE, {0x1F6E, 0x0345, 0}},
{0x1FAF, {0x1F6F, 0x0345, 0}},
{0x1FB0, {0x03B1, 0x0306, 0}},
{0x1FB1, {0x03B1, 0x0304, 0}},
{0x1FB2, {0x1F70, 0x0345, 0}},
{0x1FB3, {0x03B1, 0x0345, 0}},
{0x1FB4, {0x1F71, 0x0345, 0}},
{0x1FB6, {0x03B1, 0x0342, 0}},
{0x1FB7, {0x1FB6, 0x0345, 0}},
{0x1FB8, {0x0391, 0x0306, 0}},
{0x1FB9, {0x0391, 0x0304, 0}},
{0x1FBA, {0x0391, 0x0300, 0}},
{0x1FBB, {0x0391, 0x0301, 0}},
{0x1FBC, {0x0391, 0x0345, 0}},
{0x1FBE, {0x0399, 0}},
{0x1FC1, {0x00A8, 0x0342, 0}},
{0x1FC2, {0x1F74, 0x0345, 0}},
{0x1FC3, {0x03B7, 0x0345, 0}},
{0x1FC4, {0x1F75, 0x0345, 0}},
{0x1FC6, {0x03B7, 0x0342, 0}},
{0x1FC7, {0x1FC6, 0x0345, 0}},
{0x1FC8, {0x0395, 0x0300, 0}},
{0x1FC9, {0x0395, 0x0301, 0}},
{0x1FCA, {0x0397, 0x0300, 0}},
{0x1FCB, {0x0397, 0x0301, 0}},
{0x1FCC, {0x0397, 0x0345, 0}},
{0x1FCD, {0x1FBF, 0x0300, 0}},
{0x1FCE, {0x1FBF, 0x0301, 0}},
{0x1FCF, {0x1FBF, 0x0342, 0}},
{0x1FD0, {0x03B9, 0x0306, 0}},
{0x1FD1, {0x03B9, 0x0304, 0}},
{0x1FD2, {0x03CA, 0x0300, 0}},
{0x1FD3, {0x03CA, 0x0301, 0}},
{0x1FD6, {0x03B9, 0x0342, 0}},
{0x1FD7, {0x03CA, 0x0342, 0}},
{0x1FD8, {0x0399, 0x0306, 0}},
{0x1FD9, {0x0399, 0x0304, 0}},
{0x1FDA, {0x0399, 0x0300, 0}},
{0x1FDB, {0x0399, 0x0301, 0}},
{0x1FDD, {0x1FFE, 0x0300, 0}},
{0x1FDE, {0x1FFE, 0x0301, 0}},
{0x1FDF, {0x1FFE, 0x0342, 0}},
{0x1FE0, {0x03C5, 0x0306, 0}},
{0x1FE1, {0x03C5, 0x0304, 0}},
{0x1FE2, {0x03CB, 0x0300, 0}},
{0x1FE3, {0x03CB, 0x0301, 0}},
{0x1FE4, {0x03C1, 0x0313, 0}},
{0x1FE5, {0x03C1, 0x0314, 0}},
{0x1FE6, {0x03C5, 0x0342, 0}},
{0x1FE7, {0x03CB, 0x0342, 0}},
{0x1FE8, {0x03A5, 0x0306, 0}},
{0x1FE9, {0x03A5, 0x0304, 0}},
{0x1FEA, {0x03A5, 0x0300, 0}},
{0x1FEB, {0x03A5, 0x0301, 0}},
{0x1FEC, {0x03A1, 0x0314, 0}},
{0x1FED, {0x00A8, 0x0300, 0}},
{0x1FEE, {0x00A8, 0x0301, 0}},
{0x1FEF, {0x0060, 0}},
{0x1FF2, {0x1F7C, 0x0345, 0}},
{0x1FF3, {0x03C9, 0x0345, 0}},
{0x1FF4, {0x1F79, 0x0345, 0}},
{0x1FF6, {0x03C9, 0x0342, 0}},
{0x1FF7, {0x1FF6, 0x0345, 0}},
{0x1FF8, {0x039F, 0x0300, 0}},
{0x1FF9, {0x039F, 0x0301, 0}},
{0x1FFA, {0x03A9, 0x0300, 0}},
{0x1FFB, {0x03A9, 0x0301, 0}},
{0x1FFC, {0x03A9, 0x0345, 0}},
{0x1FFD, {0x00B4, 0}},
{0x2000, {0x2002, 0}},
{0x2001, {0x2003, 0}},
{0x2126, {0x03A9, 0}},
{0x212A, {0x004B, 0}},
{0x212B, {0x00C5, 0}},
{0x2204, {0x2203, 0x0338, 0}},
{0x2209, {0x2208, 0x0338, 0}},
{0x220C, {0x220B, 0x0338, 0}},
{0x2224, {0x2223, 0x0338, 0}},
{0x2226, {0x2225, 0x0338, 0}},
{0x2241, {0x007E, 0x0338, 0}},
{0x2244, {0x2243, 0x0338, 0}},
{0x2247, {0x2245, 0x0338, 0}},
{0x2249, {0x2248, 0x0338, 0}},
{0x2260, {0x003D, 0x0338, 0}},
{0x2262, {0x2261, 0x0338, 0}},
{0x226D, {0x224D, 0x0338, 0}},
{0x226E, {0x003C, 0x0338, 0}},
{0x226F, {0x003E, 0x0338, 0}},
{0x2270, {0x2264, 0x0338, 0}},
{0x2271, {0x2265, 0x0338, 0}},
{0x2274, {0x2272, 0x0338, 0}},
{0x2275, {0x2273, 0x0338, 0}},
{0x2278, {0x2276, 0x0338, 0}},
{0x2279, {0x2277, 0x0338, 0}},
{0x2280, {0x227A, 0x0338, 0}},
{0x2281, {0x227B, 0x0338, 0}},
{0x2284, {0x2282, 0x0338, 0}},
{0x2285, {0x2283, 0x0338, 0}},
{0x2288, {0x2286, 0x0338, 0}},
{0x2289, {0x2287, 0x0338, 0}},
{0x22AC, {0x22A2, 0x0338, 0}},
{0x22AD, {0x22A8, 0x0338, 0}},
{0x22AE, {0x22A9, 0x0338, 0}},
{0x22AF, {0x22AB, 0x0338, 0}},
{0x22E0, {0x227C, 0x0338, 0}},
{0x22E1, {0x227D, 0x0338, 0}},
{0x22E2, {0x2291, 0x0338, 0}},
{0x22E3, {0x2292, 0x0338, 0}},
{0x22EA, {0x22B2, 0x0338, 0}},
{0x22EB, {0x22B3, 0x0338, 0}},
{0x22EC, {0x22B4, 0x0338, 0}},
{0x22ED, {0x22B5, 0x0338, 0}},
{0x2329, {0x3008, 0}},
{0x232A, {0x3009, 0}},
{0x2474, {0x0028, 0x0031, 0x0029, 0}},
{0x2475, {0x0028, 0x0032, 0x0029, 0}},
{0x2476, {0x0028, 0x0033, 0x0029, 0}},
{0x2477, {0x0028, 0x0034, 0x0029, 0}},
{0x2478, {0x0028, 0x0035, 0x0029, 0}},
{0x2479, {0x0028, 0x0036, 0x0029, 0}},
{0x247A, {0x0028, 0x0037, 0x0029, 0}},
{0x247B, {0x0028, 0x0038, 0x0029, 0}},
{0x247C, {0x0028, 0x0039, 0x0029, 0}},
{0x247D, {0x0028, 0x0031, 0x0030, 0x0029, 0}},
{0x247E, {0x0028, 0x0031, 0x0031, 0x0029, 0}},
{0x247F, {0x0028, 0x0031, 0x0032, 0x0029, 0}},
{0x2480, {0x0028, 0x0031, 0x0033, 0x0029, 0}},
{0x2481, {0x0028, 0x0031, 0x0034, 0x0029, 0}},
{0x2482, {0x0028, 0x0031, 0x0035, 0x0029, 0}},
{0x2483, {0x0028, 0x0031, 0x0036, 0x0029, 0}},
{0x2484, {0x0028, 0x0031, 0x0037, 0x0029, 0}},
{0x2485, {0x0028, 0x0031, 0x0038, 0x0029, 0}},
{0x2486, {0x0028, 0x0031, 0x0039, 0x0029, 0}},
{0x2487, {0x0028, 0x0032, 0x0030, 0x0029, 0}},
{0x2488, {0x0031, 0x002E, 0}},
{0x2489, {0x0032, 0x002E, 0}},
{0x248A, {0x0033, 0x002E, 0}},
{0x248B, {0x0034, 0x002E, 0}},
{0x248C, {0x0035, 0x002E, 0}},
{0x248D, {0x0036, 0x002E, 0}},
{0x248E, {0x0037, 0x002E, 0}},
{0x248F, {0x0038, 0x002E, 0}},
{0x2490, {0x0039, 0x002E, 0}},
{0x2491, {0x0031, 0x0030, 0x002E, 0}},
{0x2492, {0x0031, 0x0031, 0x002E, 0}},
{0x2493, {0x0031, 0x0032, 0x002E, 0}},
{0x2494, {0x0031, 0x0033, 0x002E, 0}},
{0x2495, {0x0031, 0x0034, 0x002E, 0}},
{0x2496, {0x0031, 0x0035, 0x002E, 0}},
{0x2497, {0x0031, 0x0036, 0x002E, 0}},
{0x2498, {0x0031, 0x0037, 0x002E, 0}},
{0x2499, {0x0031, 0x0038, 0x002E, 0}},
{0x249A, {0x0031, 0x0039, 0x002E, 0}},
{0x249B, {0x0032, 0x0030, 0x002E, 0}},
{0x249C, {0x0028, 0x0061, 0x0029, 0}},
{0x249D, {0x0028, 0x0062, 0x0029, 0}},
{0x249E, {0x0028, 0x0063, 0x0029, 0}},
{0x249F, {0x0028, 0x0064, 0x0029, 0}},
{0x24A0, {0x0028, 0x0065, 0x0029, 0}},
{0x24A1, {0x0028, 0x0066, 0x0029, 0}},
{0x24A2, {0x0028, 0x0067, 0x0029, 0}},
{0x24A3, {0x0028, 0x0068, 0x0029, 0}},
{0x24A4, {0x0028, 0x0069, 0x0029, 0}},
{0x24A5, {0x0028, 0x006A, 0x0029, 0}},
{0x24A6, {0x0028, 0x006B, 0x0029, 0}},
{0x24A7, {0x0028, 0x006C, 0x0029, 0}},
{0x24A8, {0x0028, 0x006D, 0x0029, 0}},
{0x24A9, {0x0028, 0x006E, 0x0029, 0}},
{0x24AA, {0x0028, 0x006F, 0x0029, 0}},
{0x24AB, {0x0028, 0x0070, 0x0029, 0}},
{0x24AC, {0x0028, 0x0071, 0x0029, 0}},
{0x24AD, {0x0028, 0x0072, 0x0029, 0}},
{0x24AE, {0x0028, 0x0073, 0x0029, 0}},
{0x24AF, {0x0028, 0x0074, 0x0029, 0}},
{0x24B0, {0x0028, 0x0075, 0x0029, 0}},
{0x24B1, {0x0028, 0x0076, 0x0029, 0}},
{0x24B2, {0x0028, 0x0077, 0x0029, 0}},
{0x24B3, {0x0028, 0x0078, 0x0029, 0}},
{0x24B4, {0x0028, 0x0079, 0x0029, 0}},
{0x24B5, {0x0028, 0x007A, 0x0029, 0}},
{0x304C, {0x304B, 0x3099, 0}},
{0x304E, {0x304D, 0x3099, 0}},
{0x3050, {0x304F, 0x3099, 0}},
{0x3052, {0x3051, 0x3099, 0}},
{0x3054, {0x3053, 0x3099, 0}},
{0x3056, {0x3055, 0x3099, 0}},
{0x3058, {0x3057, 0x3099, 0}},
{0x305A, {0x3059, 0x3099, 0}},
{0x305C, {0x305B, 0x3099, 0}},
{0x305E, {0x305D, 0x3099, 0}},
{0x3060, {0x305F, 0x3099, 0}},
{0x3062, {0x3061, 0x3099, 0}},
{0x3065, {0x3064, 0x3099, 0}},
{0x3067, {0x3066, 0x3099, 0}},
{0x3069, {0x3068, 0x3099, 0}},
{0x3070, {0x306F, 0x3099, 0}},
{0x3071, {0x306F, 0x309A, 0}},
{0x3073, {0x3072, 0x3099, 0}},
{0x3074, {0x3072, 0x309A, 0}},
{0x3076, {0x3075, 0x3099, 0}},
{0x3077, {0x3075, 0x309A, 0}},
{0x3079, {0x3078, 0x3099, 0}},
{0x307A, {0x3078, 0x309A, 0}},
{0x307C, {0x307B, 0x3099, 0}},
{0x307D, {0x307B, 0x309A, 0}},
{0x3094, {0x3046, 0x3099, 0}},
{0x309E, {0x309D, 0x3099, 0}},
{0x30AC, {0x30AB, 0x3099, 0}},
{0x30AE, {0x30AD, 0x3099, 0}},
{0x30B0, {0x30AF, 0x3099, 0}},
{0x30B2, {0x30B1, 0x3099, 0}},
{0x30B4, {0x30B3, 0x3099, 0}},
{0x30B6, {0x30B5, 0x3099, 0}},
{0x30B8, {0x30B7, 0x3099, 0}},
{0x30BA, {0x30B9, 0x3099, 0}},
{0x30BC, {0x30BB, 0x3099, 0}},
{0x30BE, {0x30BD, 0x3099, 0}},
{0x30C0, {0x30BF, 0x3099, 0}},
{0x30C2, {0x30C1, 0x3099, 0}},
{0x30C5, {0x30C4, 0x3099, 0}},
{0x30C7, {0x30C6, 0x3099, 0}},
{0x30C9, {0x30C8, 0x3099, 0}},
{0x30D0, {0x30CF, 0x3099, 0}},
{0x30D1, {0x30CF, 0x309A, 0}},
{0x30D3, {0x30D2, 0x3099, 0}},
{0x30D4, {0x30D2, 0x309A, 0}},
{0x30D6, {0x30D5, 0x3099, 0}},
{0x30D7, {0x30D5, 0x309A, 0}},
{0x30D9, {0x30D8, 0x3099, 0}},
{0x30DA, {0x30D8, 0x309A, 0}},
{0x30DC, {0x30DB, 0x3099, 0}},
{0x30DD, {0x30DB, 0x309A, 0}},
{0x30F4, {0x30A6, 0x3099, 0}},
{0x30F7, {0x30EF, 0x3099, 0}},
{0x30F8, {0x30F0, 0x3099, 0}},
{0x30F9, {0x30F1, 0x3099, 0}},
{0x30FA, {0x30F2, 0x3099, 0}},
{0x30FE, {0x30FD, 0x3099, 0}},
{0xFB2A, {0x05E9, 0x05C1, 0}},
{0xFB2B, {0x05E9, 0x05C2, 0}},
{0xFB2C, {0x05E9, 0x05BC, 0x05C1, 0}},
{0xFB2D, {0x05E9, 0x05BC, 0x05C2, 0}},
{0xFB2E, {0x05D0, 0x05B7, 0}},
{0xFB2F, {0x05D0, 0x05B8, 0}},
{0xFB30, {0x05D0, 0x05BC, 0}},
{0xFB31, {0x05D1, 0x05BC, 0}},
{0xFB32, {0x05D2, 0x05BC, 0}},
{0xFB33, {0x05D3, 0x05BC, 0}},
{0xFB34, {0x05D4, 0x05BC, 0}},
{0xFB35, {0x05D5, 0x05BC, 0}},
{0xFB36, {0x05D6, 0x05BC, 0}},
{0xFB38, {0x05D8, 0x05BC, 0}},
{0xFB39, {0x05D9, 0x05BC, 0}},
{0xFB3A, {0x05DA, 0x05BC, 0}},
{0xFB3B, {0x05DB, 0x05BC, 0}},
{0xFB3C, {0x05DC, 0x05BC, 0}},
{0xFB3E, {0x05DE, 0x05BC, 0}},
{0xFB40, {0x05E0, 0x05BC, 0}},
{0xFB41, {0x05E1, 0x05BC, 0}},
{0xFB43, {0x05E3, 0x05BC, 0}},
{0xFB44, {0x05E4, 0x05BC, 0}},
{0xFB46, {0x05E6, 0x05BC, 0}},
{0xFB47, {0x05E7, 0x05BC, 0}},
{0xFB48, {0x05E8, 0x05BC, 0}},
{0xFB49, {0x05E9, 0x05BC, 0}},
{0xFB4A, {0x05EA, 0x05BC, 0}},
{0xFB4B, {0x05D5, 0x05B9, 0}},
{0xFB4C, {0x05D1, 0x05BF, 0}},
{0xFB4D, {0x05DB, 0x05BF, 0}},
{0xFB4E, {0x05E4, 0x05BF, 0}}
};
static const unsigned int
uni_dec_table_size = sizeof(uni_dec_table) / sizeof(struct _dec_);
