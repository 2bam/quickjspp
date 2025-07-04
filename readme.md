# In this fork

## Update QuickJS dependency to version 2025-04-26. 

Fix module loading to keep old API semantics.
-  In quickjs, now modules that fail to load do not return a JS_EXCEPTION but a
   rejected promise. Added handling in quickjspp in order to maintain the
   previous expected API which throws a qjs::exception on eval failure
   (`exception.cpp` test)

Fix null context access.
 - Added a JS_RunGC at the qjs::Context dtor, otherwise the unhandled rejections
   called upon finalization tried to access the opaque value of an already freed
   JSContext.
 
Fix quickjspp code and cmake issues.  
Update git patches to match new version of quicks.  
Remove bignum support (removed from QuickJS).  
Add QuickJS LICENSE file.  

Update QuickJS to match https://github.com/bellard/quickjs/ master.  
Commit date Sat Jun 28 17:41:58 2025 +0200  
Commit hash 458c34d29d0d262f824ea1c0e01aa0e3790669da  

# Original README
QuickJSPP is QuickJS wrapper for C++. It allows you to easily embed Javascript engine into your program.

QuickJS is a small and embeddable Javascript engine. It supports the ES2020 specification including modules, asynchronous generators and proxies. More info: <https://bellard.org/quickjs/>

# Example
```cpp
#include "quickjspp.hpp"
#include <iostream>

class MyClass
{
public:
    MyClass() {}
    MyClass(std::vector<int>) {}

    double member_variable = 5.5;
    std::string member_function(const std::string& s) { return "Hello, " + s; }
};

void println(qjs::rest<std::string> args) {
    for (auto const & arg : args) std::cout << arg << " ";
    std::cout << "\n";
}

int main()
{
    qjs::Runtime runtime;
    qjs::Context context(runtime);
    try
    {
        // export classes as a module
        auto& module = context.addModule("MyModule");
        module.function<&println>("println");
        module.class_<MyClass>("MyClass")
                .constructor<>()
                .constructor<std::vector<int>>("MyClassA")
                .fun<&MyClass::member_variable>("member_variable")
                .fun<&MyClass::member_function>("member_function");
        // import module
        context.eval(R"xxx(
            import * as my from 'MyModule';
            globalThis.my = my;
        )xxx", "<import>", JS_EVAL_TYPE_MODULE);
        // evaluate js code
        context.eval(R"xxx(
            let v1 = new my.MyClass();
            v1.member_variable = 1;
            let v2 = new my.MyClassA([1,2,3]);
            function my_callback(str) {
              my.println("at callback:", v2.member_function(str));
            }
        )xxx");

        // callback
        auto cb = (std::function<void(const std::string&)>) context.eval("my_callback");
        cb("world");
    }
    catch(qjs::exception)
    {
        auto exc = context.getException();
        std::cerr << (std::string) exc << std::endl;
        if((bool) exc["stack"])
            std::cerr << (std::string) exc["stack"] << std::endl;
        return 1;
    }
}
```

# Installation
QuickJSPP is header-only - put quickjspp.hpp into your include search path.
Compiler that supports C++17 or later is required.
The program needs to be linked against QuickJS.
Sample CMake project files are provided.

# License
QuickJSPP is licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/). QuickJS is licensed under [MIT](https://opensource.org/licenses/MIT).
