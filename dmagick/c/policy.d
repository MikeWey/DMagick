module dmagick.c.policy;

import core.stdc.stdio;

import dmagick.c.exception;
import dmagick.c.magickType;

extern(C)
{
	enum PolicyDomain
	{
		UndefinedPolicyDomain,
		CoderPolicyDomain,
		DelegatePolicyDomain,
		FilterPolicyDomain,
		PathPolicyDomain,
		ResourcePolicyDomain,
		SystemPolicyDomain
	}

	enum PolicyRights
	{
		UndefinedPolicyRights = 0x00,
		NoPolicyRights = 0x00,
		ReadPolicyRights = 0x01,
		WritePolicyRights = 0x02,
		ExecutePolicyRights = 0x04
	}

	struct PolicyInfo {}

	char*  GetPolicyValue(const(char)* name);
	char** GetPolicyList(const(char)*, size_t*, ExceptionInfo*);

	const(PolicyInfo)** GetPolicyInfoList(const(char)*, size_t*, ExceptionInfo*);

	MagickBooleanType IsRightsAuthorized(const PolicyDomain, const PolicyRights, const(char)*);
	MagickBooleanType ListPolicyInfo(FILE*, ExceptionInfo*);
	MagickBooleanType PolicyComponentGenesis();

	void PolicyComponentTerminus();
}
