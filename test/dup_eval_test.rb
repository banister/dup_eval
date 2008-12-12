require 'test/unit'

require File.dirname(__FILE__) + "/../lib/dup_eval"

class Dup_EvalTest < Test::Unit::TestCase
    def setup
        @p = Proc.new do
            assert_equal :bink, bink
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

        @c = Class.new
        @c.class_eval do
            def bink
                :bink
            end
        end
    end

    def test_mixing_in_module
        Module.new.dup_eval(@m, &@p)
    end

    def test_mixing_in_object
        Module.new.dup_eval(@o, &@p)
    end

    def test_mixing_in_class
        Module.new.dup_eval(@c, &@p)
    end
end
