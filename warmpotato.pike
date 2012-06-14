constant version="0.0.1";
mapping G=([]);

object bootstrap(string c)
{
	program compiled;
	mixed ex=catch {compiled=compile_file(c);};
	if (ex) {werror("Compilation failed for "+c+"\n"); werror(ex->describe()+"\n"); return 0;}
	if (!compiled) {werror("Compilation failed for "+c+"\n"); return 0;}
	return compiled(c);
}

void sighup()
{
	bootstrap("config.pike");
	G->parse_config();
}

int main(int argc,array(string) argv)
{
	add_constant("G",this);
	mapping arg=Arg.parse(argv);
	if (arg->v) {write("WarmPotato v%s\n",version); return 0;}
	G->configfile=sizeof(arg[Arg.REST]) ? arg[Arg.REST][0] : "warmpotato.conf";
	sighup(); signal(1,sighup);
	if (!G->config) return 1; //Initialization failure
	return -1;
}
