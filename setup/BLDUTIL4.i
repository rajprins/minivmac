/*
	BLDUTIL4.i
	Copyright (C) 2009 Paul C. Pratt

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
	BuiLD system UTILities part 4
*/

LOCALPROC WriteMakeOutputDirectories(void)
{
	/*
		Xcode creates its own build directory, so there is nothing
		to make here.
	*/
}

LOCALPROC WriteIdeSpecificFiles(void)
{
	WriteXCDSpecificFiles();
}

LOCALPROC ResetAllCommandLineParameters(void)
{
	GNResetCommandLineParameters();
	GNDevResetCommandLineParameters();
#ifdef Have_SPBLDOPT
	SPResetCommandLineParameters();
#endif
	olv_cur = 1;
	OnlyUserOptions = falseblnr;
}

LOCALFUNC tMyErr TryAsAtOptionNot(void)
{
	tMyErr err;

	if (! CurArgIsCStr_v2("@")) {
		err = kMyErrNoMatch;
	} else
	if (OnlyUserOptions) {
		err = ReportParseFailure("Already have @");
	} else
	if (kMyErr_noErr != (err = AdvanceTheArg())) {
		/* fail */
	} else
	{
		OnlyUserOptions = trueblnr;
		err = kMyErr_noErr;
	}

	return err;
}

LOCALFUNC tMyErr TryAsXClmOptionNot(void)
{
	tMyErr err;

	if (! CurArgIsCStr_v2("!")) {
		err = kMyErrNoMatch;
	} else
	if (kMyErr_noErr != (err = AdvanceTheArg())) {
		/* fail */
	} else
	{
		err = kMyErr_noErr;
		++olv_cur;
	}

	return err;
}

LOCALFUNC tMyErr ReportUnknownSwitch(void)
{
	MyPStr t0;
	MyPStr t;

	GetCurArgAsPStr(t0);
	PStrFromCStr(t, "unknown switch : ");
	PStrAppend(t, t0);

	return ReportParseFailPStr(t);
}

LOCALFUNC tMyErr ProcessCommandLineArguments(void)
{
	tMyErr err;

	err = kMyErr_noErr;
	while ((! The_arg_end) && (kMyErr_noErr == err)) {
		if (kMyErrNoMatch == (err = TryAsGNOptionNot()))
		if (kMyErrNoMatch == (err = TryAsGNDevOptionNot()))
#ifdef Have_SPBLDOPT
		if (kMyErrNoMatch == (err = TryAsSPOptionNot()))
#endif
		if (kMyErrNoMatch == (err = TryAsAtOptionNot()))
		if (kMyErrNoMatch == (err = TryAsXClmOptionNot()))
		{
			err = ReportUnknownSwitch();
		}
	}

	return err;
}

LOCALPROC WriteConfigFiles(void)
{
	WriteAppSpecificConfigFiles();
}


LOCALPROC MakeConfigFolder(void)
{
	WriteSectionCommentDestFile("make configuration folder");

	MakeSubDirectory("my_config_d", "my_project_d", cfg_d_name, "");
}

LOCALPROC WriteAppVariationStr1(void)
{
	WriteBgnDestFileLn();
	WriteAppVariationStr();
	WriteEndDestFileLn();
}

LOCALPROC WriteBldOpts1(void)
{
	WriteBgnDestFileLn();
	WriteBldOpts();
	WriteEndDestFileLn();
}

LOCALFUNC tMyErr DoTheCommand(void)
{
	tMyErr err;

	ResetAllCommandLineParameters();

	if (kMyErr_noErr == (err = ProcessCommandLineArguments()))
	if (kMyErr_noErr == (err = AutoChooseGNSettings()))
	if (kMyErr_noErr == (err = AutoChooseGNDevSettings()))
#ifdef Have_SPBLDOPT
	if (kMyErr_noErr == (err = AutoChooseSPSettings()))
#endif
	{
		WriteScriptLangHeader();

		if (CurPrintVarName) {
			WriteADstFile1("my_project_d",
				"var_name", "", "variation name",
				WriteAppVariationStr1);
		}

		if (CurPrintVarOpts) {
			WriteADstFile1("my_project_d",
				"bld_opts", "", "build options",
				WriteBldOpts1);
		}

		WriteMakeOutputDirectories();

		MakeConfigFolder();

		WriteConfigFiles();

		WriteIdeSpecificFiles();

		if (CurPrintCFiles) {
			WriteCFilesList();
		}
	}

	return err;
}
