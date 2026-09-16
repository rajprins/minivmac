/*
	USFILDEF.i
	Copyright (C) 2007 Paul C. Pratt

	You can redistribute this file and/or modify it under the terms
	of version 2 of the GNU General Public License as published by
	the Free Software Foundation.  You should have received a copy
	of the license along with this file; see the file COPYING.

	This file is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	license for more details.
*/

/*
	USe program SPecific FILe DEFinitions
*/

LOCALVAR unsigned int FileCounter;

struct DoSrcFile_r
{
	MyPtr SavepDt;
	char *s;
	long Flgm;
	int DepDir;
	tDoDependsForC depends;
	MyProc p;
};

typedef struct DoSrcFile_r DoSrcFile_r;

#define DoSrcFile_gd() ((DoSrcFile_r *)(pDt))

LOCALPROC DoASrcFileWithSetupProc0(
	char *s, int DepDir, long Flgm, tDoDependsForC depends)
{
	DoSrcFile_gd()->s = s;
	DoSrcFile_gd()->Flgm = Flgm;
	DoSrcFile_gd()->DepDir = DepDir;
	DoSrcFile_gd()->depends = depends;

	DoSrcFile_gd()->p();

	++FileCounter;
}

LOCALPROC DoASrcFileWithSetupProc(
	char *s, int DepDir, long Flgm, tDoDependsForC depends)
{
	if (0 == (Flgm & kCSrcFlgmNoSource))
	if (0 == (Flgm & kCSrcFlgmSkip))
	{
		DoASrcFileWithSetupProc0(s, DepDir, Flgm, depends);
	}
}

LOCALPROC DoAllSrcFilesWithSetup(MyProc p)
{
	DoSrcFile_r r;

	r.SavepDt = pDt;
	r.p = p;
	pDt = (MyPtr)&r;

	FileCounter = 0;
	DoAllSrcFiles(DoASrcFileWithSetupProc);

	pDt = r.SavepDt;
}

LOCALPROC DoAllSrcFilesSortWithSetup1(
	char *s, int DepDir, long Flgm, tDoDependsForC depends)
{
	if (0 == (Flgm & kCSrcFlgmNoSource))
	if (0 == (Flgm & kCSrcFlgmSkip))
	{
		if (0 != (Flgm & kCSrcFlgmSortFirst)) {
			DoASrcFileWithSetupProc0(s, DepDir, Flgm, depends);
		} else {
			++FileCounter;
		}
	}
}

LOCALPROC DoAllSrcFilesSortWithSetup2(
	char *s, int DepDir, long Flgm, tDoDependsForC depends)
{
	if (0 == (Flgm & kCSrcFlgmNoSource))
	if (0 == (Flgm & kCSrcFlgmSkip))
	{
		if (0 == (Flgm & kCSrcFlgmSortFirst)) {
			DoASrcFileWithSetupProc0(s, DepDir, Flgm, depends);
		} else {
			++FileCounter;
		}
	}
}

LOCALPROC DoAllSrcFilesSortWithSetup(MyProc p)
{
	DoSrcFile_r r;

	r.SavepDt = pDt;
	r.p = p;
	pDt = (MyPtr)&r;

	FileCounter = 0;
	DoAllSrcFiles(DoAllSrcFilesSortWithSetup1);
	FileCounter = 0;
	DoAllSrcFiles(DoAllSrcFilesSortWithSetup2);

	pDt = r.SavepDt;
}

LOCALFUNC char * GetSrcFileFileXtns(void)
{
	char *s;
	blnr UseObjc = ((DoSrcFile_gd()->Flgm & kCSrcFlgmOjbc) != 0);

	if (UseObjc) {
		s = ".m";
	} else {
		s = ".c";
	}

	return s;
}

LOCALPROC WriteSrcFileFileName(void)
{
	WriteCStrToDestFile(DoSrcFile_gd()->s);
	WriteCStrToDestFile(GetSrcFileFileXtns());
}

LOCALPROC WriteSrcFileFilePath(void)
{
	WriteFileInDirToDestFile0(Write_src_d_ToDestFile,
		WriteSrcFileFileName);
}

LOCALPROC WriteSrcFileHeaderName(void)
{
	WriteCStrToDestFile(DoSrcFile_gd()->s);
	WriteCStrToDestFile(".h");
}

LOCALPROC WriteSrcFileHeaderPath(void)
{
	WriteFileInDirToDestFile0(Write_src_d_ToDestFile,
		WriteSrcFileHeaderName);
}

LOCALPROC DoAllExtraHeaders2WithSetupProc(
	char *s, int DepDir, long Flgm, tDoDependsForC depends)
{
	if (0 == (Flgm & kCSrcFlgmNoHeader))
	if (0 != (Flgm & kCSrcFlgmNoSource))
	if (0 == (Flgm & kCSrcFlgmSkip))
	{
		DoASrcFileWithSetupProc0(s, DepDir, Flgm, depends);
	}
}

LOCALPROC DoAllExtraHeaders2WithSetup(MyProc p)
{
	DoSrcFile_r r;

	r.SavepDt = pDt;
	r.p = p;
	pDt = (MyPtr)&r;

	FileCounter = 0;
	DoAllSrcFiles(DoAllExtraHeaders2WithSetupProc);

	pDt = r.SavepDt;
}

LOCALPROC WriteExtraHeaderFileName(void)
{
	WriteCStrToDestFile(DoSrcFile_gd()->s);
	WriteCStrToDestFile(".h");
}

LOCALPROC WriteExtraHeaderFilePath(void)
{
	WriteFileInDirToDestFile0(
		((kDepDirCnfg == DoSrcFile_gd()->DepDir)
			? Write_cfg_d_ToDestFile
			: Write_src_d_ToDestFile),
		WriteExtraHeaderFileName);
}

LOCALVAR unsigned int DocTypeCounter;

struct DoDocType_r
{
	MyPtr SavepDt;
	char *ShortName;
	char *MacType;
	char *LongName;
	tWriteExtensionList WriteExtensionList;
	MyProc p;
};

typedef struct DoDocType_r DoDocType_r;

#define DoDocType_gd() ((DoDocType_r *)(pDt))

LOCALPROC DoAllDocTypesWithSetupProc(char *ShortName,
	char *MacType,
	char *LongName,
	tWriteExtensionList WriteExtensionList)
{
	DoDocType_gd()->ShortName = ShortName;
	DoDocType_gd()->MacType = MacType;
	DoDocType_gd()->LongName = LongName;
	DoDocType_gd()->WriteExtensionList = WriteExtensionList;

	DoDocType_gd()->p();

	++DocTypeCounter;
}

LOCALPROC DoAppAndAllDocTypes0(tWriteOneDocType p)
{
	p("APP", "APPL", "Application", NULL);
	DoAllDocTypes(p);
}

LOCALPROC DoAppAndAllDocTypes(tWriteOneDocType p)
{
	p("APP", "APPL", "Application", NULL);
	if (WantIconMaster) {
		DoAllDocTypes(p);
	}
}

LOCALPROC DoAllDocTypesWithSetup(MyProc p)
{
	DoDocType_r r;

	r.SavepDt = pDt;
	r.p = p;
	pDt = (MyPtr)&r;

	DocTypeCounter = 0;
	DoAppAndAllDocTypes(DoAllDocTypesWithSetupProc);

	pDt = r.SavepDt;
}

LOCALPROC WriteDocTypeIconShortName(void)
{
	WriteCStrToDestFile(DoDocType_gd()->ShortName);
}

LOCALPROC WriteDocTypeIconFileName(void)
{
	WriteCStrToDestFile("ICON");
	WriteDocTypeIconShortName();
	WriteCStrToDestFile("O.icns");
}

LOCALPROC WriteDocTypeIconFilePath(void)
{
	WriteFileInDirToDestFile0(Write_src_d_ToDestFile,
		WriteDocTypeIconFileName);
}

LOCALPROC WriteDocTypeIconMacType(void)
{
	WriteCStrToDestFile(DoDocType_gd()->MacType);
}

typedef void (*tWriteOneFrameWorkType)(char *s);

static void DoAllFrameWorks(tWriteOneFrameWorkType p)
{
	p("AppKit");
	p("AudioUnit");
#if UseOpenGLinOSX
	p("OpenGL");
#endif
}

struct DoFrameWork_r
{
	MyPtr SavepDt;
	char *s;
	MyProc p;
};

typedef struct DoFrameWork_r DoFrameWork_r;

#define DoFrameWork_gd() ((DoFrameWork_r *)(pDt))

LOCALPROC DoAllFrameWorksWithSetupProc(char *s)
{
	DoFrameWork_gd()->s = s;

	DoFrameWork_gd()->p();

	++FileCounter;
}

LOCALPROC DoAllFrameWorksWithSetup(MyProc p)
{
	DoFrameWork_r r;

	r.SavepDt = pDt;
	r.p = p;
	pDt = (MyPtr)&r;

	FileCounter = 0;
	DoAllFrameWorks(DoAllFrameWorksWithSetupProc);

	pDt = r.SavepDt;
}

LOCALPROC WriteFileToCFilesList(MyProc p)
{
	WriteBgnDestFileLn();
	p();
	WriteEndDestFileLn();
}

LOCALPROC DoSrcExtraHeaderFile(void)
{
	WriteFileToCFilesList(WriteExtraHeaderFilePath);
}

LOCALPROC DoSrcFileAddToList(void)
{
	WriteFileToCFilesList(WriteSrcFileHeaderPath);
	WriteFileToCFilesList(WriteSrcFileFilePath);
}

LOCALPROC WriteCFilesListContents(void)
{
	DoAllExtraHeaders2WithSetup(DoSrcExtraHeaderFile);
	DoAllSrcFilesWithSetup(DoSrcFileAddToList);
}

LOCALPROC WriteCFilesList(void)
{
	/* list of c files */

	WriteADstFile1("my_project_d",
		"c_files", "", "list of c files",
		WriteCFilesListContents);
}
