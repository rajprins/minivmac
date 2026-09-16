/*
	BLDUTIL3.i
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
	BuiLD system UTILities part 3
*/


#define src_d_name "src"
#define cfg_d_name "cfg"

#define obj_d_name "bld"
	/* not "obj", so as to work in freebsd make */

LOCALVAR blnr HaveAltSrc;

LOCALPROC WritepDtString(void)
{
	WriteCStrToDestFile((char *)pDt);
}

LOCALPROC WriteMaintainerName(void)
{
	WriteCStrToDestFile(vMaintainerName);
}

LOCALPROC WriteHomePage(void)
{
	WriteCStrToDestFile(vHomePage);
}

/* end of default value of options */

LOCALPROC WriteVersionStr(void)
{
	WriteDec2CharToOutput(MajorVersion);
	WriteCStrToDestFile(".");
	WriteDec2CharToOutput(MinorVersion);
}

LOCALPROC WriteAppVariationStr(void)
{
	if (nullpr != vVariationName) {
		WriteCStrToDestFile(vVariationName);
	} else {
		WriteCStrToDestFile(vStrAppAbbrev);
		WriteCStrToDestFile("-");
		WriteNUimrToDestFile(MajorVersion, 2);
		WriteCStrToDestFile(".");
		WriteNUimrToDestFile(MinorVersion, 2);
		WriteCStrToDestFile("-");
		WriteCStrToDestFile(kTargetName);
		/* WriteCStrToDestFile(GetDbgLvlName(gbo_dbg)); */
	}
}

LOCALPROC WriteAppCopyrightYearStr(void)
{
	WriteCStrToDestFile(kStrCopyrightYear);
}

LOCALPROC WriteGetInfoString(void)
{
	WriteAppVariationStr();
	WriteCStrToDestFile(", Copyright ");
	WriteAppCopyrightYearStr();
	WriteCStrToDestFile(" maintained by ");
	WriteMaintainerName();
	WriteCStrToDestFile(".");
}

LOCALPROC WriteLProjName(void)
{
	WriteCStrToDestFile(GetLProjName(gbo_lang));
}

/* --- XML utilities --- */

LOCALPROC WriteXMLtagBegin(char *s)
{
	WriteCStrToDestFile("<");
	WriteCStrToDestFile(s);
	WriteCStrToDestFile(">");
}

LOCALPROC WriteXMLtagEnd(char *s)
{
	WriteCStrToDestFile("</");
	WriteCStrToDestFile(s);
	WriteCStrToDestFile(">");
}

LOCALPROC WriteBeginXMLtagLine(char *s)
{
	WriteBgnDestFileLn();
	WriteXMLtagBegin(s);
	WriteEndDestFileLn();
	++DestFileIndent;
}

LOCALPROC WriteEndXMLtagLine(char *s)
{
	--DestFileIndent;
	WriteBgnDestFileLn();
	WriteXMLtagEnd(s);
	WriteEndDestFileLn();
}

LOCALPROC WriteXMLtagBeginValEndLine(char *t, char *v)
{
	WriteBgnDestFileLn();
	WriteXMLtagBegin(t);
	WriteCStrToDestFile(v);
	WriteXMLtagEnd(t);
	WriteEndDestFileLn();
}

LOCALPROC WriteXMLtagBeginProcValEndLine(char *t, MyProc v)
{
	WriteBgnDestFileLn();
	WriteXMLtagBegin(t);
	v();
	WriteXMLtagEnd(t);
	WriteEndDestFileLn();
}

/* --- end XML utilities --- */

/* --- c preprocessor utilities --- */

LOCALPROC WriteCompCondBool(char *s, blnr v)
{
	WriteBgnDestFileLn();
	WriteCStrToDestFile("#define ");
	WriteCStrToDestFile(s);
	if (v) {
		WriteCStrToDestFile(" 1");
	} else {
		WriteCStrToDestFile(" 0");
	}
	WriteEndDestFileLn();
}

LOCALPROC WriteDefineUimr(char *s, uimr v)
{
	WriteBgnDestFileLn();
	WriteCStrToDestFile("#define ");
	WriteCStrToDestFile(s);
	WriteSpaceToDestFile();
	WriteUnsignedToOutput(v);
	WriteEndDestFileLn();
}

LOCALPROC WriteCDefQuote(char *s, MyProc p)
{
	WriteBgnDestFileLn();
	WriteCStrToDestFile("#define ");
	WriteCStrToDestFile(s);
	WriteSpaceToDestFile();
	WriteQuoteToDestFile();
	p();
	WriteQuoteToDestFile();
	WriteEndDestFileLn();
}

/* --- end c preprocessor utilities --- */

LOCALPROC WritePathInDirToDestFile0(MyProc p, MyProc ps,
	blnr isdir)
{
	if (p != NULL) {
		p();
	}
	ps();
	if (isdir) {
		WriteCStrToDestFile("/");
	}
}

LOCALPROC WriteFileInDirToDestFile0(MyProc p, MyProc ps)
{
	WritePathInDirToDestFile0(p, ps, falseblnr);
}

LOCALPROC WriteSubDirToDestFile(MyProc p, MyProc ps)
{
	WritePathInDirToDestFile0(p, ps, trueblnr);
}

LOCALPROC Write_toplevel_d_ToDestFile(MyProc ps)
{
	WritePathInDirToDestFile0(NULL, ps, trueblnr);
}

LOCALPROC Write_src_d_Name(void)
{
	WriteCStrToDestFile(src_d_name);
}

LOCALPROC Write_src_d_ToDestFile(void)
{
	Write_toplevel_d_ToDestFile(Write_src_d_Name);
}

LOCALPROC Write_cfg_d_Name(void)
{
	WriteCStrToDestFile(cfg_d_name);
}

LOCALPROC Write_cfg_d_ToDestFile(void)
{
	Write_toplevel_d_ToDestFile(Write_cfg_d_Name);
}

LOCALPROC WriteLProjFolderName(void)
{
	WriteLProjName();
	WriteCStrToDestFile(".lproj");
}

LOCALPROC WriteLProjFolderPath(void)
{
	WriteSubDirToDestFile(Write_cfg_d_ToDestFile,
		WriteLProjFolderName);
}

LOCALPROC WriteStrAppAbbrev(void)
{
	WriteCStrToDestFile(vStrAppAbbrev);
}

LOCALPROC WriteAppNameStr(void)
{
	WriteStrAppAbbrev();
	WriteCStrToDestFile(".app");
}

LOCALPROC WriteStrAppUnabrevName(void)
{
	WriteCStrToDestFile(kStrAppName);
}

LOCALPROC Write_contents_d_Name(void)
{
	WriteCStrToDestFile("Contents");
}

LOCALPROC Write_macos_d_Name(void)
{
	WriteCStrToDestFile("MacOS");
}

LOCALPROC Write_tmachobun_d_Name(void)
{
	WriteCStrToDestFile("AppTemp");
}

LOCALPROC Write_tmachobun_d_ToDestFile(void)
{
	Write_toplevel_d_ToDestFile(Write_tmachobun_d_Name);
}

LOCALPROC Write_tmachocontents_d_ToDestFile(void)
{
	WriteSubDirToDestFile(Write_tmachobun_d_ToDestFile,
		Write_contents_d_Name);
}

LOCALPROC Write_tmachomac_d_ToDestFile(void)
{
	WriteSubDirToDestFile(Write_tmachocontents_d_ToDestFile,
		Write_macos_d_Name);
}

LOCALPROC Write_tmachobinpath_ToDestFile(void)
{
	WriteFileInDirToDestFile0(Write_tmachomac_d_ToDestFile,
		WriteStrAppAbbrev);
}

LOCALPROC Write_umachobun_d_Name(void)
{
	WriteStrAppAbbrev();
	WriteCStrToDestFile("_u.app");
}

LOCALPROC Write_umachobun_d_ToDestFile(void)
{
	Write_toplevel_d_ToDestFile(Write_umachobun_d_Name);
}

LOCALPROC Write_umachocontents_d_ToDestFile(void)
{
	WriteSubDirToDestFile(Write_umachobun_d_ToDestFile,
		Write_contents_d_Name);
}

LOCALPROC Write_umachomac_d_ToDestFile(void)
{
	WriteSubDirToDestFile(Write_umachocontents_d_ToDestFile,
		Write_macos_d_Name);
}

LOCALPROC Write_umachobinpath_ToDestFile(void)
{
	WriteFileInDirToDestFile0(Write_umachomac_d_ToDestFile,
		WriteStrAppAbbrev);
}

LOCALPROC WriteInfoPlistFileName(void)
{
	WriteCStrToDestFile("Info.plist");
}

LOCALPROC WriteInfoPlistFilePath(void)
{
	WriteFileInDirToDestFile0(Write_cfg_d_ToDestFile,
		WriteInfoPlistFileName);
}

LOCALPROC WriteDummyLangFileName(void)
{
	WriteCStrToDestFile("dummy.txt");
}

LOCALPROC Write_MacCreatorSigOrGeneric(void)
{
	if (WantIconMaster) {
		WriteCStrToDestFile(kMacCreatorSig);
	} else {
		WriteCStrToDestFile("????");
	}
}

/*
	Classic Macintosh resource-fork resources (main.r / main.rc) are
	not used by a Mach-O Cocoa bundle, so the functions that named and
	located them are gone along with src/main.r itself.
*/

LOCALPROC WriteCNFUIOSGName(void)
{
	WriteCStrToDestFile("CNFUIOSG.h");
}

LOCALPROC WriteCNFUIOSGPath(void)
{
	WriteFileInDirToDestFile0(Write_cfg_d_ToDestFile,
		WriteCNFUIOSGName);
}
