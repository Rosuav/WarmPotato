//Config file parser for Warm Potato

void create(string n)
{
	G->G->parse_config=parse_config;
}

void parse_config()
{
	object configobj=G->bootstrap(G->G->configfile);
	if (!configobj) {werror("Unable to load config file %s\n",G->G->configfile); return;}
	mapping config=configobj->config; if (!config) {werror("No config mapping in config file %s\n",G->G->configfile); return;}
	write("%O\n",config);
	//TODO: Load everything needed and make whatever changes we need. This includes reloading any code that's changed.
	G->G->config=config; //Atomically apply the configuration changes. Everything will either continue with the old or take the new.
}
