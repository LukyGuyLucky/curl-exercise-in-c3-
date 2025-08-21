import curl;

import std;

const URL="http://www.bing.com";

fn void test1(String url_str)
{
    Curl* curl;
    
    curl=curl::easy_init();
    defer curl::easy_cleanup(curl);
    if(!curl)
    {
       io::printfn("Failed to connect to %s",url_str);
    }
    io::printfn("Successfully connected to %s",url_str);
     curl::easy_setopt(curl,curl::CURLOPT_VERBOSE,true);
     curl::easy_setopt(curl,curl::CURLOPT_URL,url_str);
     curl::easy_perform(curl);
    
    
}

fn void main(String[] args)
{
    test1(args.len<2?URL:args[1]);
}