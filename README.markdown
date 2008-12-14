Dup\_eval
========

This is an alternative to \_why's mix\_eval C extension. It provides identical functionality to mix\_eval as well as the following extra 
functionality:
* Ability to mix in Objects/Classes (using Object2module)
* Thread-safety

Dup\_eval is a development on work originally by coderrr (http://coderrr.wordpress.com) and based on his cool idea for dupping the binding of a block 
(http://coderrr.wordpress.com/2008/11/14/making-mixico-thread-safe/)

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