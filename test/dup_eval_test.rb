require 'test/unit'

require File.dirname(__FILE__) + "/../lib/dup_eval"

class Dup_EvalTest < Test::Unit::TestCase
    def setup
        @p = Proc.new do
            assert_equal :bink, bink
            assert_equal :local_method, local_method
        end

        @p2 = Proc.new do
            assert_equal :bink, bink
            assert_equal :bunk, bunk
            assert_equal :local_method, local_method
        end

        @m = Module.new do
            def bink
                :bink
            end
        end

        @o = Object.new
        class << @o
            def bink
                :bink
            end
        end

        @o2 = Object.new
        class <<@o2
            def bunk
                :bunk
            end
        end

        @c = Class.new
        @c.class_eval do
            def bink
                :bink
            end
        end
    end

    #a method in the local binding
    #used for testing
    def local_method
        :local_method
    end

    def test_mixing_in_self_when_object
        o = Object.new
        class << o
            def bink
                :bink
            end
        end

        o.dup_eval(&@p)
    end

    def test_mixing_in_self_when_class
        c = Class.new
        c.class_eval do
            def bink
                :bink
            end
        end

        c.dup_eval(&@p)
    end

    def test_mixing_in_module
        Module.new.dup_eval_with(@m, &@p)
    end

    def test_mixing_in_object
        Module.new.dup_eval_with(@o, &@p)
    end

    def test_mixing_in_class
        Module.new.dup_eval_with(@c, &@p)
    end

    def test_mixing_in_multi_objects
        Module.new.dup_eval_with(@o, @o2, &@p2)
    end
end
