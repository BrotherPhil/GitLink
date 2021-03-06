(* ::Package:: *)

Needs["GitLink`"];
$TestRepos = FileNameJoin[{NotebookDirectory[], "repos"}];
$RepoDirectory = FileNameJoin[{$TemporaryDirectory, "AddResetTestRepo"}];
Quiet[DeleteDirectory[$RepoDirectory, DeleteContents->True]];
$Repo = GitClone[FileNameJoin[{$TestRepos, "testrepo", ".gitted"}], $RepoDirectory];
SetDirectory[$RepoDirectory];
changefile[filename_] := Module[{strm = OpenAppend[filename]},
	WriteString[strm, "\nnew line\n"]; Close[strm]];
fullpath[path_] := FileNameJoin[{$RepoDirectory, path}]


VerificationTest[
	{
		GitRepoQ[$RepoDirectory]
		, AssociationQ[GitProperties[$Repo]]
		, Flatten[Values[GitStatus[$Repo]]] === {}
	},
	{True, True, True}
]


(* ::Subsubsection:: *)
(*Add a new file*)


VerificationTest[
	Export["newfile.txt", Range[5], "Text"];
	{
		GitAdd[$Repo, "newfile.txt"] === {"newfile.txt"}
		, GitStatus[$Repo]["IndexNew"] === {"newfile.txt"}
	},
	{True, True}
]


(* ::Subsubsection:: *)
(*Reset the file*)


VerificationTest[
	{
		GitReset[$Repo, "newfile.txt"] === {"newfile.txt"}
		, GitStatus[$Repo]["IndexNew"] === {}
	},
	{True, True}
]
DeleteFile["newfile.txt"]


(* ::Subsubsection:: *)
(*One-argument add*)


VerificationTest[
	Export["newfile.txt", Range[5], "Text"];
	{
		GitAdd[FileNameJoin[fullPath["newfile.txt"]]] === {fullPath["newfile.txt"]}
		, Values@GitStatus[$Repo][[{"New","IndexNew"}]] === {{},{"newfile.txt"}}
	},
	{True, True}
]


(* ::Subsubsection:: *)
(*One-argument reset*)


VerificationTest[
	{
		GitReset[fullPath["newfile.txt"]] === {fullPath["newfile.txt"]}
		, Values@GitStatus[$Repo][[{"New","IndexNew"}]] === {{"newfile.txt"},{}}
	},
	{True, True}
]
DeleteFile["newfile.txt"]


(* ::Subsubsection:: *)
(*Add a directory*)


VerificationTest[
	CreateDirectory["newdir"];
	filelist = FileNameJoin[{"newdir", #}]& /@ {"abc.txt", "def.txt"};
	Scan[Export[#, "abc", "Text"]&, filelist];

	{
		GitAdd[$Repo, "newdir"] === filelist
		, Sort[Values@GitStatus[$Repo][[{"New","IndexNew"}]]] === {{}, Sort[filelist]}
	}
	,
	{True, True}
]


(* ::Subsubsection:: *)
(*Reset the directory*)


VerificationTest[
	{
		Sort[GitReset[$Repo, "newdir"]] === Sort[filelist]
		, Values@GitStatus[$Repo][[{"New","IndexNew"}]] === {Sort[filelist],{}}
	}
	,
	{True, True}
]
DeleteDirectory["newdir", DeleteContents->True];


(* ::Subsubsection:: *)
(*Add a change*)


VerificationTest[
	changefile["new.txt"];

	{
		GitAdd[$Repo, "new.txt"] === {"new.txt"}
		, Values@GitStatus[$Repo][[{"Modified","IndexModified"}]] === {{},{"new.txt"}}
	}
	,
	{True, True}
]


(* ::Subsubsection:: *)
(*Reset a change*)


VerificationTest[
	{
		GitReset[$Repo, "new.txt"] === {"new.txt"}
		, Values@GitStatus[$Repo][[{"Modified","IndexModified"}]] === {{"new.txt"},{}}
	}
	,
	{True, True}
]
GitLink`Private`GitCheckoutFiles[$Repo,"HEAD","CheckoutStrategy"->"Force"];


(* ::Subsubsection:: *)
(*Add a deletion*)


VerificationTest[
	DeleteFile["README"];

	{
		Values@GitStatus[$Repo][[{"Deleted", "IndexDeleted"}]] === {{"README"}, {}}
		, GitAdd[$Repo, "README"] === {"README"}
		, Values@GitStatus[$Repo][[{"Deleted", "IndexDeleted"}]] === {{}, {"README"}}
	}
	,
	{True, True, True}
]


(* ::Subsubsection:: *)
(*Reset a deletion*)


VerificationTest[
	{
		GitReset[$Repo, "README"] === {"README"}
		, Values@GitStatus[$Repo][[{"Deleted","IndexDeleted"}]] === {{"README"},{}}
	}
	,
	{True, True}
]
GitLink`Private`GitCheckoutFiles[$Repo,"HEAD","CheckoutStrategy"->"Force"];


(* ::Subsubsection:: *)
(*Add a change to a new file*)


VerificationTest[
	Export["newfile.txt", Range[5], "Text"];
	GitAdd[$Repo, "newfile.txt"];
	changefile["newfile.txt"];

	{
		Values@GitStatus[$Repo][[{"Modified", "IndexNew"}]] === {{"newfile.txt"}, {"newfile.txt"}}
		, GitAdd[$Repo, "newfile.txt"] === {"newfile.txt"}
		, Values@GitStatus[$Repo][[{"Modified", "IndexNew"}]] === {{}, {"newfile.txt"}}
	}
	,
	{True, True, True}
]


(* ::Subsubsection:: *)
(*Delete new file, then reset the file*)


VerificationTest[
	DeleteFile["newfile.txt"];
	{
		GitReset[$Repo, "newfile.txt"] === {"newfile.txt"}
		, Flatten[Values@GitStatus[$Repo]] === {}
	}
	,
	{True, True}
]


ResetDirectory[];
GitClose[$Repo];
DeleteDirectory[$RepoDirectory, DeleteContents->True];
