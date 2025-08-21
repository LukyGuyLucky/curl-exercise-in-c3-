
import easycurl;
import std;

const WEBPAGE="http://www.baidu.com";

fn int main(String[] args)
{
    EasyCurl obj;
    obj.init(args.len<2? WEBPAGE:args[1]);

    io::printfn(obj.fetch());

    return 0;

}
