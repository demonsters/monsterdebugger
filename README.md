
**Please note: The Monster Debugger is currently not supported or maintained. No sweat, the entire project is open source and you came to the right place to download everything! - Dev team De Monsters Amsterdam**

The MonsterDebugger is a free, open source debugging tool for Adobe Flash, Flex and AIR based applications. It's designed to be useful for both starting and skilled developers and it focuses on five major tasks during the development of your application:

1. Tracing messages
2. Introspection of your application structure
3. Testing methods
4. Editing properties
5. Finding performance issues

While there are many different debuggers available for Flash developers, we believe the Monster Debugger has a combination of elements that none of the other have to offer. The main advantages above other (commercial) debuggers are:

1. It's free and open source, which means that you can now build, debug and publish your Adobe Flash applications with a complete line of open source tools such as the Adobe Flex SDK, Flash Develop and of course the Monster Debugger.
2. You can connect to the Monster Debugger even when your application runs on a desktop, webserver or mobile device. There is no need for special debug builds or debug players. We even support a zero configuration mode to connect your mobile device to our debugger over WIFI.
3. It supports editing properties and running methods on runtime. This eliminates the need to recompile your application every time you want to edit a value or test a method.
4. We have a game that shows you how awesome the new debugger is!


# Quick start

Getting started with the Monster Debugger is really easy. Just take the following steps and you'll be up and running in no time:

1. Download and install the Adobe AIR runtime from: http://get.adobe.com/air/
2. Download and install the Monster Debugger.
3. Export the client SWC file from the Monster Debugger to your own project.
4. Link the client SWC file to your project (read more about this in the next chapter).
5. Initialise the debugger in your main class:

```as3
package {
 
    import com.demonsters.debugger.MonsterDebugger;
    import flash.display.Sprite;
     
    public class Main extends Sprite {
 
        public function Main() {
 
            // Start the MonsterDebugger
            MonsterDebugger.initialize(this);
            MonsterDebugger.trace("Hello World!");
        }
    }
}           
```

Publish your project and watch the magic happen.
This basic setup works for all Adobe Flash, Flex and AIR applications. In the following chapters we will focus on more specific use cases like the new Flex component and mobile debugging.



# Wiki

https://github.com/demonsters/monsterdebugger/wiki

# FAQ

https://github.com/demonsters/monsterdebugger/wiki/13.-FAQ