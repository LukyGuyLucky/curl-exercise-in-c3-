import curl;
import libc;
import std::collections::map;
//import std;



alias Headers_t=HashMap{String,String};

struct EasyCurl
{

    Curl* handle;
    String url;
    String data;
    String upload_data;

}

fn void EasyCurl.setOptions(&self)
{
    CURLcode res;
    
    res=curl::easy_setopt(self.handle,curl::CURLOPT_URL,self.url.ptr);
    if(res!=curl::CURLcode.CURLE_OK)
    {
        libc::fprintf(libc::stderr(),"Failed to set url.");

        return;
    }

    res=curl::easy_setopt(self.handle,curl::CURLOPT_NOPROGRESS,1);
    if(res!=curl::CURLcode.CURLE_OK)
    {
        libc::fprintf(libc::stderr(),"Failed to set NOPROGRESS");

        return;
    }

    res=curl::easy_setopt(self.handle,curl::CURLOPT_SSL_VERIFYHOST,0);
    if(res!=curl::CURLcode.CURLE_OK)
    {
        libc::fprintf(libc::stderr(),"Failed to set SSL_VERIFYHOST");

        return;
    }
    res=curl::easy_setopt(self.handle,curl::CURLOPT_WRITEFUNCTION,&easycurl_write_data_cb);
    if(res!=curl::CURLcode.CURLE_OK)
    {
        libc::fprintf(libc::stderr(),"Failed to set writefunction");

        return;
    }

    res=curl::easy_setopt(self.handle,curl::CURLOPT_WRITEDATA,self);
    if(res!=curl::CURLcode.CURLE_OK)
    {
        libc::fprintf(libc::stderr(),"Failed to set WRITEDATA");

        return;
    }
}
fn void EasyCurl.setHttpHeaders(&self,Headers_t hdrs)
{
    if(hdrs.is_empty())
    {
        Slist* chunk=null;
        hdrs.@each(;String key,String value)
        {
            String h=string::tformat("%s: %s",key,value);
            chunk=curl::slist_append(chunk,h.ptr);
        };
        CURLcode res=curl::easy_setopt(self.handle,curl::CURLOPT_HTTPHEADER,chunk);
        if(res!=curl::CURLcode.CURLE_OK)
        {
            libc::fprintf(libc::stderr(),"Failed to set options to curl.");

            return;
        }
    }

}
fn void EasyCurl.perform(&self)
{
    CURLcode res;
    res=curl::easy_perform(self.handle);
    if(res!=curl::CURLcode.CURLE_OK)
    {
        libc::fprintf(libc::stderr(),"Failed to perform actions on curl.");

        return;
    }
}
fn bool EasyCurl.isHttpError(&self)
{
    long httpReturnCode;
    curl::easy_getinfo(self.handle,curl::CURLINFO_RESPONSE_CODE,&httpReturnCode);
    if(httpReturnCode<200||httpReturnCode>300)
    {
        return true;
    }
    return false;
}

fn isz EasyCurl.append_data(&self,void* ptr,isz size,isz nmemb)
{
    isz bytes=size* nmemb;
    ZString s=(ZString)ptr;
    DString temp;
    temp.append_chars(self.data);
    temp.append_chars((String)s[:libc::strlen(s)]);
    //self.data=self.data.tconcat(string::tformat("%s",(String)s[:libc::strlen((ZString)s)]));
    self.data=temp.str_view();
    return bytes;
    
}

fn isz EasyCurl.upload_datas(&self,void* ptr,isz size,isz nmemb)
{
    isz upload_max=size*nmemb;
    isz to_send=min(self.upload_data.len,upload_max);
    libc::memcpy(ptr,self.upload_data.ptr,to_send);
    self.upload_data=self.upload_data[to_send..self.upload_data.len-1];

    return to_send;

}

fn String EasyCurl.fetch(&self)
{
    self.setOptions();
    self.perform();

    return self.data;
}
fn String EasyCurl.post(&self,String data,Headers_t hdrs)
{
    CURLcode res;
    res=curl::easy_setopt(self.handle,curl::CURLOPT_POST,1);
    if(res!=curl::CURLcode.CURLE_OK)
    {
        libc::fprintf(libc::stderr(),"Failed to post.");

        return "";
    }
    res=curl::easy_setopt(self.handle,curl::CURLOPT_POSTFIELDS,data.ptr);
    if(res!=curl::CURLcode.CURLE_OK)
    {
        libc::fprintf(libc::stderr(),"Failed to post field.");

        return "";
    }

    res=curl::easy_setopt(self.handle,curl::CURLOPT_POSTFIELDSIZE,data.len);
    if(res!=curl::CURLcode.CURLE_OK)
    {
        libc::fprintf(libc::stderr(),"Failed to post field size");

        return "";
    }
    self.setOptions();
    self.setHttpHeaders(hdrs);
    self.perform();

    return self.data;

}
fn String EasyCurl.put(&self,String data,Headers_t hdrs)
{
    CURLcode res;
    self.setOptions();

    res=curl::easy_setopt(self.handle,curl::CURLOPT_UPLOAD,1);
    if(res!=curl::CURLcode.CURLE_OK)
    {
        libc::fprintf(libc::stderr(),"Failed to set UPLOAD option.");

        return "";
    }

    res=curl::easy_setopt(self.handle,curl::CURLOPT_READFUNCTION,&easycurl_read_data_cb);
    if(res!=curl::CURLcode.CURLE_OK)
    {
        libc::fprintf(libc::stderr(),"Failed to set ReadFunction.");

        return "";
    }

    res=curl::easy_setopt(self.handle,curl::CURLOPT_READDATA,self);
    if(res!=curl::CURLcode.CURLE_OK)
    {
        libc::fprintf(libc::stderr(),"Failed to set READDATA");

        return "";
    }

    self.upload_data=data;
    res=curl::easy_setopt(self.handle,curl::CURLOPT_INFILESIZE,(long)data.len);
    if(res!=curl::CURLcode.CURLE_OK)
    {
        libc::fprintf(libc::stderr(),"Failed to set InFileSize");

        return "";
    }

    self.setHttpHeaders(hdrs);
    self.perform();

    return self.data;
}

fn EasyCurl* EasyCurl.new(&self)
{
    self.handle=curl::easy_init();
    if(self.handle==null)
    {
        libc::fprintf(libc::stderr(),"Failed to initialize curl.");

        return null;
    }

    return self;

}
fn void EasyCurl.free(&self)
{
    curl::easy_cleanup(self.handle);
}

fn EasyCurl* EasyCurl.init(&self,String url)
{
    self.handle=curl::easy_init();
    if(self.handle==null)
    {
        libc::fprintf(libc::stderr(),"Unable to initialize curl handler");

        return null;
    }
    if(url.len==0)
    {
        libc::fprintf(libc::stderr(),"Url can't be of zero length.");

        return null;
    }

    self.url=url;

    return self;
}

fn isz easycurl_write_data_cb(void* ptr,isz size,isz nmemb,void* pInstance)
{
    EasyCurl* obj=(EasyCurl*)(pInstance);

    return obj.append_data(ptr,size,nmemb);
}
fn isz easycurl_read_data_cb(void* ptr,isz size,isz nmemb,void* pInstance)
{
    EasyCurl* obj=(EasyCurl*)pInstance;

    return obj.upload_datas(ptr,size,nmemb);
}