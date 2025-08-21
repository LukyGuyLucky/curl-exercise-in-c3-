
import easycurl;
import std;

const WEBPAGE="http://www.baidu.com";

fn int main(String[] args)
{
    EasyCurl obj;
    if(args.len<2)
    {
        obj.init(WEBPAGE);
    }
    else
    {
        obj.init(args[1]);
    }

    io::printfn(obj.fetch());

    return 0;
}