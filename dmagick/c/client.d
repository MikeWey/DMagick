module dmagick.c.client;

extern(C)
{
	const(char)* GetClientPath();
	const(char)* GetClientName();
	const(char)* SetClientName(const(char)*);
	const(char)* SetClientPath(const(char)*);
}
