/*
 *  gitLink
 *
 *  Created by John Fultz on 6/18/14.
 *  Copyright (c) 2014 Wolfram Research. All rights reserved.
 *
 */

#ifndef GitLinkRepository_h_
#define GitLinkRepository_h_ 1

#include "GitLinkSuperClass.h"
#include "MLExpr.h"
 
const mint BAD_KEY = -1;

class Signature;

class GitLinkRepository : public GitLinkSuperClass
{
public:
	GitLinkRepository(const std::string& key);
	GitLinkRepository(const MLExpr& expr);
	GitLinkRepository(MLINK link)
		: GitLinkRepository(MLExpr(link))
	{ };

	/// For newly created git_repositories which don't have don't have
	/// an in-kernel instance, yet
	GitLinkRepository(git_repository* repo, WolframLibraryData libData);

	~GitLinkRepository();



	bool isValid() const { return repo_ != NULL; };

	std::string key() const { return key_; };
	void unsetKey();

	git_repository* repo() const { return repo_; };

	/// Recreates the signature every time...but the signature is mutable in this class
	/// Note that you *must* NULL-check this, as it can fail
	const git_signature* committer() const;

	bool fetch(WolframLibraryData libData, const char* remoteName, const char* privateKeyFile, const MLExpr& prune, const MLExpr& downloadTags);

	bool push(WolframLibraryData libData, const char* remoteName, const char* privateKeyFile, const char* branch);

	bool setHead(const char* refName);

	bool checkoutHead(WolframLibraryData libData, const MLExpr& strategy, const MLExpr& notifyFlags);

	void writeProperties(MLINK lnk, bool shortForm) const;

	void writeRemotes(MLHelper& helper) const;

	git_tree* copyTree(const MLExpr& expr);

	git_revwalk* revWalker() const;

	static int AcquireCredsCallBack(git_cred** cred,const char* url,const char *username,unsigned int allowed_types, void* payload);

private:
	git_repository* repo_;
	mutable Signature* committer_;
	std::string key_;
	char* remoteName_;
	mutable git_revwalk* revWalker_ = NULL;

	GitLinkRepository(const GitLinkRepository& repo) { };

	void openCachedRepo_();
	bool setRemote_(WolframLibraryData libData, const char* remoteName, const char* privateKeyFile);
	bool connectRemote_(git_direction direction);
	void writeConflictList_(MLHelper& helper) const;
	void writeBranchList_(MLHelper& helper, git_branch_t flag) const;
	void writeTagList_(MLHelper& helper) const;


	static int pushCallBack_(const char* ref, const char* msg, void* data);

};

#endif // GitLinkRepository_h_
