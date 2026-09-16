/*
	WRTEXTFL.i
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
	WRite TEXT FiLe
*/



/* --- routines for writing text files --- */


#define WriteCharToOutput putchar

LOCALPROC WriteCStrToOutput(char *s)
{
	printf("%s", s);
}

LOCALPROC WriteSignedLongToOutput(long int v)
{
	printf("%ld", v);
}

LOCALPROC WriteUnsignedToOutput(unsigned int v)
{
	printf("%u", v);
}

LOCALPROC WriteDec2CharToOutput(int v)
{
	printf("%02u", v);
}

LOCALPROC WriteHexByteToOutput(unsigned int v)
{
	printf("%02X", v);
}

LOCALPROC WriteHexWordToOutput(unsigned int v)
{
	printf("%04X", v);
}

LOCALPROC WriteHexLongToOutput(ui5r v)
{
	printf("%08lX", v);
}

LOCALPROC WriteEolToOutput(void)
{
	printf("\n");
}

LOCALPROC WriteLnCStrToOutput(char *s)
{
	WriteCStrToOutput(s);
	WriteEolToOutput();
}


/* --- code for writing the generated bash script --- */

/*
	The generator used to be able to emit MPW, AppleScript, VBScript
	and Windows XP batch scripts as well. Only bash remains.
*/

GLOBALPROC WriteScriptLangHeader(void)
{
	WriteLnCStrToOutput("#! /bin/bash");
	WriteEolToOutput();
}

GLOBALPROC WriteSectionCommentDestFile(char * Description)
{
	WriteEolToOutput();
	WriteEolToOutput();

	WriteCStrToOutput("# ----- ");
	WriteCStrToOutput(Description);
	WriteCStrToOutput(" -----");

	WriteEolToOutput();
}

LOCALPROC WriteOpenDestFile(char *DirVar, char *FileName, char *FileExt,
	char * Description)
{
	if (nullpr != Description) {
		WriteSectionCommentDestFile(Description);
	}

	WriteEolToOutput();

	WriteCStrToOutput("DestFile=\"${");
	WriteCStrToOutput(DirVar);
	WriteCStrToOutput("}");
	WriteCStrToOutput(FileName);
	WriteCStrToOutput(FileExt);
	WriteCStrToOutput("\"");
	WriteEolToOutput();
	WriteLnCStrToOutput("printf \"\" > \"${DestFile}\"");
	WriteEolToOutput();
}

LOCALPROC WriteCloseDestFile(void)
{
}

TYPEDEFPROC (*MyProc)(void);

LOCALPROC WriteADstFile1(char *DirVar,
	char *FileName, char *FileExt, char * Description, MyProc p)
{
	WriteOpenDestFile(DirVar, FileName, FileExt, Description);
	p();
	WriteCloseDestFile();
}

LOCALPROC WriteBlankLineToDestFile(void)
{
	WriteLnCStrToOutput("printf \"\\n\" >> \"${DestFile}\"");
}

LOCALVAR int DestFileIndent = 0;

LOCALPROC WriteBgnDestFileLn(void)
{
	int i;

	WriteCStrToOutput("printf \"%s\\n\" '");

	for (i = 0; i < DestFileIndent; ++i) {
		WriteCStrToOutput("\t");
	}
}

LOCALPROC WriteEndDestFileLn(void)
{
	WriteCStrToOutput("' >> \"${DestFile}\"");

	WriteEolToOutput();
}

LOCALPROC WriteCharsToDestFile(char *p, uimr n)
{
	simr i;
	char c;

	for (i = n; --i >= 0; ) {
		if ('\'' == (c = *p++)) {
			WriteCStrToOutput("'\\''");
		} else {
			WriteCharToOutput(c);
		}
	}
}

LOCALPROC MakeSubDirectory(char *new_d, char *parent_d, char *name,
	char *FileExt)
{
	WriteEolToOutput();

	WriteCStrToOutput(new_d);
	WriteCStrToOutput("=\"${");
	WriteCStrToOutput(parent_d);
	WriteCStrToOutput("}");
	WriteCStrToOutput(name);
	WriteCStrToOutput(FileExt);
	WriteCStrToOutput("/\"");
	WriteEolToOutput();

	WriteCStrToOutput("if test ! -d \"${");
	WriteCStrToOutput(new_d);
	WriteCStrToOutput("}\" ; then");
	WriteEolToOutput();

	WriteCStrToOutput("\tmkdir \"${");
	WriteCStrToOutput(new_d);
	WriteCStrToOutput("}\"");
	WriteEolToOutput();

	WriteLnCStrToOutput("fi");
}



/* ------- utilities for writing to text files -------- */

LOCALPROC WriteCharToDestFile(char c)
{
	WriteCharsToDestFile(&c, 1);
}

LOCALPROC WriteCStrToDestFile(char *s)
{
	WriteCharsToDestFile(s, CStrLength(s));
}

LOCALPROC WritePStrToDestFile(ps3p s)
{
	MyCharPtr p = s;
	MyCharR n = *p++;

	WriteCharsToDestFile((char *)p, n);
}

LOCALPROC WriteDestFileLn(char *s)
{
	WriteBgnDestFileLn();
	WriteCStrToDestFile(s);
	WriteEndDestFileLn();
}

LOCALPROC WriteSpaceToDestFile(void)
{
	WriteCharToDestFile(' ');
}

LOCALPROC WriteQuoteToDestFile(void)
{
	WriteCharToDestFile('\"');
}

LOCALPROC WriteBackSlashToDestFile(void)
{
	WriteCharToDestFile('\\');
}

LOCALPROC WriteNUimrToDestFile(uimr v, ui3r n)
{
	MyPStr s;

	PStrFromNUimr(v, n, s);
	WritePStrToDestFile(s);
}
