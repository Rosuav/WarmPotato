//Sample WarmPotato site-class file

string host; //Note: The host is used as-is for every request. DNS is not cached. This may need to be improved.
int port;

//Initialize a site based on the given parameters. If anything goes wrong, throw an error.
void create(string params)
{
	sscanf(params,"%s:%d",host,port);
	if (!port) error("Usage: proxy:host:port");
	//Maybe TODO: Do a DNS lookup on the host immediately, and fail if it's wrong.
}

void request(mapping config,Protocols.HTTP.Server.Request req)
{
	write("Request: %s\n",req->request_raw);
	write("%O %O %O\n%O\n-----\n%O\n==========\n",host,port,req->request_raw,req->request_headers,req->body_raw);
	//Note: It would be more efficient to implement this at a lower level, simply passing the request along byte-for-byte, but it's safer to unpack and repack it.
	Protocols.HTTP.Query()->set_callbacks(ok,fail,config,req)->async_request(host,port,req->request_raw,req->request_headers,req->body_raw);
}

void ok(Protocols.HTTP.Query query,mapping config,Protocols.HTTP.Server.Request req)
{
	req->response_and_finish((["data":query->data(),"extra_heads":query->headers]));
}

void fail(Protocols.HTTP.Query query,mapping config,Protocols.HTTP.Server.Request req)
{
	req->response_and_finish((["data":"Unable to connect to "+host+" port "+port,"error":504]));
}
