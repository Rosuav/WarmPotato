//WarmPotato site-class file: File system
//Serves files as content, no changes at all.
//TODO: Make the cache parameters configurable

string basepath; //File-system path to the web site root
int cachelen=300; //Cache for 5 minutes
int statage=60; //Will check file_stat after 1 minute (and immediately mark it stale if the mod time has changed)
mapping(string:object) cache=([]);

class cached
{
	int fresh; //Timestamp last checked for freshness
	int mtime;
	string data;
	void create(string fn)
	{
		fresh=time();
		mtime=file_stat(fn)->mtime;
		cache[fn]=this;
	}
	int is_stale(string fn)
	{
		int t=time();
		if (t>fresh+cachelen) return 1;
		if (t<fresh+statage) return 0;
		return mtime!=file_stat(fn)->mtime;
	}
}

//Initialize a site based on the given parameters. If anything goes wrong, throw an error.
void create(mapping config,string params)
{
	if (!file_stat(basepath=params)) error("Path not found: "+params);
}

void request(mapping config,Protocols.HTTP.Server.Request req)
{
	write("Request: %O %O\n",req->not_query,req->query);
	string path=combine_path(basepath,Protocols.HTTP.uri_decode(req->not_query[1..]));
	Stdio.Stat stat=file_stat(path);
	if (!stat)
	{
		req->response_and_finish((["error":404,"data":"File not found","extra_heads":(["content-type":"text/plain"])]));
		return;
	}
	if (stat->isdir)
	{
		if (path[-1]!='/')
		{
			//Redirect http://www.example.com/foobar to http://www.example.com/foobar/ when foobar is a directory
			req->response_and_finish((["error":301,"extra_heads":(["location":req->not_query+"/"+(req->query!=""?"?":"")+req->query])]));
			return;
		}
		//Directory listing (if permitted)
		string data="<h1>Directory listing of "+req->not_query+"</h1><ul>";
		foreach (get_dir(path),string fn)
		{
			if (fn[0]=='.') continue; //Ignore dot-files (TODO: Make this configurable)
			string file=combine_path(path,fn);
			Stdio.Stat stat=file_stat(file);
			if (!stat) continue; //Shouldn't happen
			if (stat->isdir) data+=sprintf("<li><a href='%s/'>%s/</a> &lt;DIR&gt;</li>",Protocols.HTTP.uri_encode(fn),Parser.encode_html_entities(fn));
			else data+=sprintf("<li><a href='%s'>%s</a></li>",Protocols.HTTP.uri_encode(fn),Parser.encode_html_entities(fn));
		}
		req->response_and_finish((["extra_heads":(["content-type":"text/html"]),"data":data+"</ul>"]));
		return;
	}
	//TODO: Call on somebody else's MIME type detection system
	string type="application/octet-stream";
	if (has_suffix(path,".html")) type="text/html";
	else if (has_suffix(path,".txt")) type="text/plain";
	req->response_and_finish((["extra_heads":(["content-type":type]),"file":Stdio.File(path)]));
}
