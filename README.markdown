Dup\_eval
========

This is an alternative to \_why's mix\_eval C extension. It provides identical functionality to mix\_eval as well as the following extra functionality:

* Ability to mix in Objects/Classes (using Object2module)
* Thread-safety

Dup\_eval is based on coderrr's idea for dupping the binding of a block (http://coderrr.wordpress.com/2008/11/14/making-mixico-thread-safe/)

NOTE:
Dup\_eval is still in proof of concept stage, use at own risk! 

Example use:
===========

    #create our object
    o = Object.new
    
    #give it a method
    class << o
        def hello; print "Hello! "; end
    end

    #create a method in the current binding
    def goodbye; puts "Goodbye!"; end

    o.dup_eval { hello; goodbye }    #=> "Hello! Goodbye!" 

From above, both the methods of the object itself and the binding of the block are available to the block.

    #we can also choose which objects we want to eval the block with respect to (we can have more than one)
    o1 = Object.new
    class << o1; ...define methods here... end
    
    o2 = Object.new
    class << o2; ...define methods here... end

    o3 = Object.new
    class << o3; ...define methods here... end

    #create a method in the current binding
    def goodbye; puts "Goodbye!"; end

    o1.dup_eval_with(o1, o2, o3) { o1_method; o2_method; o3_method; goodbye }

As shown above we can have the block access methods in many objects (as many as we want). The objects may also be either Objects, Classes, or Modules.
