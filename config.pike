//Config file parser for Warm Potato

void create(string n)
{
	G->G->parse_config=parse_config;
}

void parse_config()
{
	string configfile=G->G->configfile;
	if (mixed ex=catch
	{
		object configobj=G->bootstrap(configfile);
		if (!configobj) {werror("Unable to load config file %s\n",configfile); return;}
		mapping config=configobj->config; if (!config) {werror("No config mapping in config file %s\n",configfile); return;}
		if (!arrayp(config->web_sites)) {werror("No web_sites element in config file %s\n",configfile); return;}
		//TODO: Load everything needed and make whatever changes we need. This includes reloading any code that's changed.
		array sites=config->web_sites;
		mapping(string:program) code=([]);
		for (int i=0;i<sizeof(sites);++i)
		{
			if (!stringp(sites[i])) {werror("Malformed web_sites element %d in config file %s\n",i,configfile); return;}
			sscanf(sites[i],"%s:%s:%s",string method,string cls,string params);
			if (!cls) {werror("Malformed web_sites element %d in config file %s\n",i,configfile); return;}
			if (!params) params="";
			//TODO: compile_file can throw errors, which currently look a tad ugly. Make it a little more helpful.
			if (!code[cls] && !(code[cls]=compile_file(cls+".pike"))) {werror("Unrecognized class '%s' in web_sites element %d in config file %s\n",cls,i,configfile); return;}
			sscanf(method,"%s %s",method,string methodargs);
			sites[i]=({method,methodargs||"",code[cls](config,params)});
		}
		config->request=request;
		G->G->config=config; //Atomically apply the configuration changes. Everything will either continue with the old or take the new.
	}) {werror("Error parsing config file %s\n%s\n",configfile,describe_error(ex)); return;}
}

void request(mapping config,Protocols.HTTP.Server.Request req)
{
	foreach (config->web_sites,array site)
	{
		//site[0] is the method, site[1] method args, site[2] the handler object
		//If not matched, 'continue'.
		switch (site[0])
		{
			case "*": break; //Always matches.
			case "host": if (lower_case(req->request_headers["host"])==lower_case(site[1])) break; else continue; //TODO: Lowercase the parameter once.
			default: continue;
		}
		site[2]->request(config,req);
		return;
	}
}
