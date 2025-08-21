import curl;

import std;
import libc;
const URL="http://www.freepascal.com";

struct MemoryStruct
{
    char* memory;
    usz size;
}
fn usz mem_cb(void* contents,usz size,usz nmemb,void* userp)
{
    usz realsize=size* nmemb;
    MemoryStruct* mems=(MemoryStruct*)userp;
    
    mems.memory=libc::realloc(mems.memory,mems.size+realsize+1);
    if(mems.memory==null)
    {
        io::printn("Not enough memory (relloc returned NULL)");
        return 0;
    }
    libc::memcpy(&(mems.memory[mems.size]),contents,realsize);
    mems.size+=realsize;
    mems.memory[mems.size]=0;
    
    return realsize;
}
/*
fn usz doWrite(void* stream,usz size,void* data)
{
    File? file=file::open("fpc.html","wb");
    return io::write_any(&file,&data)??-1;
     file.flush()!!;
    defer file.close()!!;
}
*/
fn void test1(String url_str)
{
    Curl* curl;
    CURLcode res;
    
    MemoryStruct chunk;
    chunk.memory=libc::malloc(1);
    chunk.size=0;
    
    curl::global_init(3);
    
   
    curl=curl::easy_init();
    defer curl::easy_cleanup(curl);
    if(!curl)
    {
       io::printfn("Failed to connect to %s",url_str);
    }
    io::printfn("Successfully connected to %s",url_str);
     curl::easy_setopt(curl,curl::CURLOPT_VERBOSE,true);
     curl::easy_setopt(curl,curl::CURLOPT_URL,url_str);
     curl::easy_setopt(curl,curl::CURLOPT_WRITEFUNCTION,&mem_cb);
     curl::easy_setopt(curl,curl::CURLOPT_WRITEDATA,(void*)&chunk);
     curl::easy_setopt(curl,curl::CURLOPT_USERAGENT,"libcurl-agent/1.0");
     
    res=curl::easy_perform(curl);
    if(res!=CURLcode.CURLE_OK)
    {
        libc::fprintf(libc::stderr(),"curl_easy_perform() failed:%s",
            curl::easy_strerror(res));
    }
    else
    {
        io::printfn("%d bytes retrieved.",(long)chunk.size);
    }
    
    free(chunk.memory);
    curl::global_cleanup();
    
    
}

fn void main(String[] args)
{
    test1(args.len<2?URL:args[1]);
}