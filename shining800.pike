//Custom WarmPotato site-class file: Shining Eight Hundred.

Sql.Sql db;
string editpass="";
array(mapping) books=({ });
array(string) booksel=({ });
array(mapping) verses=({ });
mapping(int:mapping) verse=([]); //Map verse ID to verse info

void create(mapping config,string params)
{
	string pwd; catch {pwd=Stdio.File("pwd.txt")->read();};
	string dbpass="";
	if (pwd) sscanf(pwd,"%s\n%s\n",dbpass,editpass); //If it couldn't be loaded, stuff will probably all fail.
	db=Sql.Sql("pgsql://shining:"+dbpass+"@localhost/shining800");
	books=db->query("select * from books");
	booksel=({"<option value=0>Select</option>"});
	foreach (books,mapping bk) booksel+=({sprintf("<option value=%s>%s</option>",bk->id,bk->fullname)});
	getverses();
}

void getverses()
{
	//Cache the verses in memory for quick lookup.
	//Note that across an update, this can become stale. It may be worth regenerating it on timer.
	//(It's automatically regenerated whenever anything's changed.)
	verses=db->query("select row_number() over (),verses.id,fullname,chapter,verse,comments from verses join books on (book=books.id) order by book,chapter,verse");
	foreach (verses,mapping v) verse[(int)v->id]=v;
}

void request(mapping config,Protocols.HTTP.Server.Request req)
{
	string func="url"+replace(req->not_query,"/","_");
	if (this[func]) {this[func](config,req); return;}
	//404 handler
	req->response_and_finish((["error":404,"extra_heads":(["content-type":"text/plain"]),"data":"Shining 800: Requested page not found"]));
}

string title(string tit) {return sprintf(#"<!doctype html>
<html>
<head>
<title>Shining Eight Hundred%s</title>
</head>
<body>
<h1>Shining Eight Hundred%[0]s</h1>",tit?": "+tit:"");}

//Index page handler
void url_(mapping config,Protocols.HTTP.Server.Request req)
{
	string verseinfo="";
	foreach (verses,mapping v) verseinfo+=sprintf("\n<tr><td><a href='/edit?id=%s'>%s. %s %s:%s</a></td><td></td><td>%s</td></tr>",v->id,v->row_number,v->fullname,v->chapter,v->verse,v->comments);
	req->response_and_finish((["extra_heads":(["content-type":"text/html"]),"data":title(0)+#"
<p>The 'Shining Eight Hundred' project seeks to catalogue all the places in the Bible where God reminds us to rejoice.
(Why do it? Because nobody else seems to have, and it seemed a good excuse to tinker with a new web server project.)</p>
<p><a href='/edit'>Add new entry</a></p>
<table border='1'><tr><th>Reference</th><th>Text (unimpl)</th><th>Comment</th></tr>"+verseinfo+"</table></body></html>"]));
}

void url_edit(mapping config,Protocols.HTTP.Server.Request req)
{
	int id=(int)req->variables->id;
	if (req->variables->pwd==editpass)
	{
		//Save (or add)
		mapping v=req->variables;
		string response="Saved.";
		if (mixed ex=catch {db->query(
			verse[id]?"update verses set book=%d,chapter=%d,verse=%d,comments=%s where id=%d"
			:"insert into verses (book,chapter,verse,comments) values (%d,%d,%d,%s)",
			(int)v->book,(int)v->chapter,(int)v->verse,v->comments,id);
		}) response="Error in saving.";
		req->response_and_finish((["extra_heads":(["content-type":"text/plain"]),"data":response]));
		getverses();
		return;
	}
	mapping info=(["book":0,"chapter":"","verse":""]);
	if (verse[id]) info=verse[id]; else id=0;
	array bookcopy=booksel+({ });
	int b=(int)info->book;
	if (b && b<sizeof(bookcopy)) bookcopy[b]=replace(bookcopy[b],"<option","<option selected");
	req->response_and_finish((["extra_heads":(["content-type":"text/html"]),"data":title("Add/edit entry")+sprintf(#"<p>
<form method=post action='/edit'>
<table>
<tr><td>Password:</td><td><input type=password name=pwd> It'd be nice to let just anybody edit, but alas I can't.</td></tr>
<tr><td>Reference:</td><td><select name=book>%s</select><input name=chapter size=3>:<input name=verse size=3></td></tr>
<tr><td>Comments:</td><td><textarea name=comments></textarea></td></tr>
</table>
<p><input type=submit value=Save title='Hallelujah!'></p><input type=hidden name=id value=%d>
</form>
</body>
</html>
",bookcopy*"",id)]));
}

void url_reload(mapping config,Protocols.HTTP.Server.Request req)
{
	G->sighup();
	req->response_and_finish((["extra_heads":(["content-type":"text/plain"]),"data":"All code reloaded."]));
}

//Command-line usage :) Install self into Postgres.
int main()
{
	foreach (({
		"drop table if exists verses",
		"drop table if exists books",
		"create table books (id serial primary key,abbr varchar not null unique,fullname varchar not null unique)",
		"create table verses (id serial primary key,book int not null references books,chapter smallint not null,verse smallint not null,comments varchar not null default '')",
	}),string stmt) db->query(stmt);

	//Populate the 'books' table with full names and abbreviations.
	//The abbreviation is everything before the slash, spaces compressed out.
	//The full name is everything, with the slash removed.
	//There are several reasons for using this, but the main one is so that Scripture references can be conveniently
	//sorted :)
	foreach (({
		"Gen/esis","Exo/dus","Lev/iticus","Num/bers","Deut/eronomy",
		"Josh/ua","Jud/ges","Ruth/","1 Sa/muel","2 Sa/muel","1 Ki/ngs","2 Ki/ngs","1 Ch/ronicles","2 Ch/ronicles",
		"Ezra/","Neh/emiah","Esth/er","Job/","Ps/alms","Prov/erbs","Eccles/isastes","Song of Sol/omon",
		"Isa/iah","Jer/emiah","Lam/entations","Ezek/ial","Dan/iel","Hos/ea","Joel/","Amos/","Obad/iah",
		"Jon/ah","Mic/ah","Nah/um","Hab/akkuk","Zeph/aniah","Hag/gai","Zech/ariah","Mal/achi",
		"Matt/hew","Mark/","Luke/","John/","Acts/","Rom/ans","1 Cor/inthians","2 Cor/inthians",
		"Gal/atians","Eph/esians","Phil/ippians","Col/ossians","1 Thes/salonians","2 Thes/salonians",
		"1 Tim/othy","2 Tim/othy","Tit/us","Philem/on","Heb/rews","Jam/es","1 Pet/er","2 Pet/er",
		"1 John/","2 John/","3 John/","Jude/","Rev/elation"
	}),string book)
	{
		sscanf(book,"%s/%s",string abbr,string tail);
		db->query("insert into books (abbr,fullname) values (%s,%s)",replace(abbr," ",""),abbr+tail);
	}
	return 0;
}
