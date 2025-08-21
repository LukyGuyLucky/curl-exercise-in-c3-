
import easycurl;
import std;

const WEBPAGE="http://cn.bing.com/";

fn int main(String[] args)
{
    EasyCurl obj;
    defer obj.free();
    obj.init(args.len<2? WEBPAGE:args[1]);

    io::printfn(obj.fetch());

    return 0;

}



